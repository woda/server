# -*- coding: utf-8 -*-
require 'time'
require 'openssl'
require 'digest/sha1'
require 'tempfile'

class SyncController < ApplicationController
  before_filter :require_login

  before_filter Proc.new { |c| c.check_params :filename }, :only => [:create_folder]
  before_filter Proc.new { |c| c.check_params :filename, :content_hash, :size }, :only => [:put, :change]
  before_filter Proc.new { |c| c.check_params :id, :part }, :only => [:upload_part, :get]
  before_filter Proc.new { |c| c.check_params :id}, :only => [:delete, :needed_parts, :synchronize]

  ##
  # Update the given file, save it and update its parent recursively 
  def update_and_save file
    raise RequestError.new(:internal_error, "Can't update and save a nil file") if file.nil?
    file.last_update = Time.now
    file.save

    file.parents.each do |parent|
      update_and_save parent
    end
  end

  ##
  # Update the parent of the given file and remove its children and itself
  def update_and_delete file
    raise RequestError.new(:internal_error, "Can't update and save a nil file") if file.nil?
    file.parents.each do |parent|
      update_and_save parent
    end
    file.delete session[:user]
  end

  ##
  # Method to use to complete an upload if all the content parts have been uploaded
  def complete_upload(content, part)
    parts = XPart.all(content: content, part_number: part)
    parts.each { |item| item.destroy! }
    if XPart.count(content: content) == 0 then
      files = WFile.all(content_hash: content.content_hash, uploaded: false)
      files.each do |item|
        item.uploaded = true
        update_and_save item
      end
      true
    else
      false
    end
  end

  ##
  # Creates and return a new folder
  def create_folder
    raise RequestError.new(:bad_param, "Parameter 'filename' is not valid") if params[:filename].nil? || params[:filename].empty?
    folder = session[:user].create_folder( params[:filename] )
    raise RequestError.new(:folder_not_created, "Folder not created") if folder.nil?
    update_and_save folder
    @result = { folder: folder.description, success: true }
  end

  ##
  # Create a file and return it. 
  def put
    raise RequestError.new(:bad_param, "Parameter 'filename' is not valid") if params[:filename].nil? || params[:filename].empty?
    raise RequestError.new(:bad_param, "Parameter 'content_hash' is not valid") if params[:content_hash].nil? || params[:content_hash].empty?
    raise RequestError.new(:bad_param, "Parameter 'size' is not valid") if params[:size].nil? || params[:size].empty?
    
    current_content = Content.first content_hash: params[:content_hash]
    already_uploaded = (current_content ? current_content.uploaded : false)
    file = session[:user].create_file params[:filename]
    if current_content && already_uploaded
      file.uploaded = true
      @result = { success: true, uploaded: true }
    else
      current_content = Content.create(params[:content_hash], params[:size].to_i) if current_content.nil?
      @result = { success: true, uploaded: false, needed_parts: current_content.needed_parts, part_size: PART_SIZE }
    end
    file.content = current_content
    update_and_save file
    @result.merge!({ file: file.description })
    session[:user].save
  end

  ##
  # Method to upload a part of 5mb for a specific file
  def upload_part
    file = XFile.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_access, "No access") unless file.users.include? session[:user]
    raise RequestError.new(:bad_param, "Can't upload data to a folder") if file.folder
    raise RequestError.new(:bad_part, "\"#{params[:part]}\" isn't an acceptable part name") unless /^[0-9]+$/ =~ params[:part]
    part = params[:part].to_i
    raise RequestError.new(:bad_part, "Content incorrect") if file.content.nil?
    raise RequestError.new(:bad_part, "Part number too high") if part > ( file.content.size / PART_SIZE )
    data = request.body.read
    part_size = (part == file.content.size / PART_SIZE ? file.content.size % PART_SIZE : PART_SIZE)
    raise RequestError.new(:bad_part, "Size of part incorrect") unless part_size == data.length
    cypher = WodaCrypt.new
    cypher.encrypt
    cypher.key = file.content.crypt_key.from_hex
    cypher.iv = WodaHash.digest(params[:part])
    bucket = Storage['woda-files']
    obj = bucket.create("#{file.content.content_hash}/#{params[:part]}", data: (cypher.update(data) + cypher.final), content_type: 'octet-stream')
    complete_upload(file.content, part)
    @result = { success: true, needed_parts: file.content.needed_parts, uploaded: file.uploaded }
  end

  ##
  # Method to get the content parts that still need to be uploaded
  def needed_parts
    file = XFile.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_access, "No access") unless file.users.include? session[:user]
    raise RequestError.new(:bad_param, "Can't upload data to a folder") if file.folder
    raise RequestError.new(:no_content, "File content found") if file.content.nil?
    @result = { success: true, needed_parts: file.content.needed_parts, uploaded: file.uploaded, file: file.description }
  end

  ##
  # Delete and recreate a file with the given parameters
  def change
    delete
    put
  end

  ##
  # Delete a file
  def delete
    file = WFile.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_access, "No access") unless file.users.include? session[:user]
    raise RequestError.new(:bad_param, "Can't delete the root folder") if file.id == session[:user].root_folder.id
    update_and_delete (file.folder ? WFolder.get(params[:id]) : file)

    @result = { success: true }
  end

  ##
  # Get the specific file corresponding to the ID given in parameters
  def get
    file = XFile.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_access, "No access") unless file.users.include? session[:user]
    raise RequestError.new(:bad_param, "Can't get a folder") if file.folder
    raise RequestError.new(:bad_part, "Content incorrect") if file.content.nil?
    raise RequestError.new(:file_not_uploaded, "File not completely uploaded") unless file.uploaded
    key = "#{file.content.content_hash}/#{params[:part]}"
    raise RequestError.new(:no_bucket, "Bucket not found") if Storage['woda-files'].nil?
    raise RequestError.new(:no_key, "Key path not found") if (Storage.use_aws ? Storage['woda-files'][key].exists? == false : Storage['woda-files'][key].nil? )
    data = Storage['woda-files'][key].read()
    if params[:part].to_i == 0 then
      file.downloads += 1
      file.save
    end
    cypher = WodaCrypt.new
    cypher.decrypt
    cypher.key = file.content.crypt_key.from_hex
    cypher.iv = WodaHash.digest(params[:part])
    @result = cypher.update(data) + cypher.final
  end

  ##
  # Method to get the timestamp of the last modification of the user's file list
  def last_update
    folder = ( params[:id].nil? ? session[:user].root_folder : XFile.get(params[:id]) )
    raise RequestError.new(:file_not_found, "Folder not found") if folder.nil?
    raise RequestError.new(:bad_access, "No access") unless folder.users.include? session[:user]   
    @result =  { last_update: folder.last_update, success: true }
  end

  ##
  # Synchronize a public file into the main folder
  def synchronize
    file = WFile.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_access, "No access") unless file.public?
    raise RequestError.new(:bad_param, "Can't synchronize a folder") if file.folder
    
    file = session[:user].create_file_from_origin file if (!params[:link])
    file = session[:user].link_file_from_origin file if (params[:link])

    update_and_save file
    @result = { success: true, file: file.description }
    session[:user].save
  end

end
