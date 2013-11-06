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
  before_filter Proc.new { |c| c.check_params :id}, :only => [:delete, :upload_success]

  ##
  # Update the given file, save it and update its parent recursively 
  def update_and_save file
    raise RequestError.new(:internal_error, "Can't update and save a nil file") if file.nil?
    file.last_update = Time.now
    file.save
    parent = session[:user].x_files.get file.x_file_id
    update_and_save parent if parent
  end

  ##
  # Update the parent of the given file and remove its children and itself
  def update_and_delete file
    raise RequestError.new(:internal_error, "Can't update and save a nil file") if file.nil?
    parent = session[:user].x_files.get file.x_file_id
    update_and_save parent if parent
    file.delete
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
    f = session[:user].create_file params[:filename]
    if current_content
      f.uploaded = true
      @result = { success: true, need_upload: false, file: f.description }
    else
      current_content = Content.new(content_hash: params[:content_hash], size: params[:size].to_i, crypt_key: WodaCrypt.new.random_key.to_hex)
      @result = { success: true, need_upload: true, file: f.description, part_size: XFile.part_size }
      current_content.save
    end
    f.content = current_content
    update_and_save f
    session[:user].save
  end

  ##
  # Method to upload a part of 5mb for a specific file
  def upload_part
    f = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless f
    raise RequestError.new(:bad_param, "Can't upload data to a folder") if f.folder
    raise RequestError.new(:bad_part, "\"#{params[:part]}\" isn't an acceptable part name") unless /^[0-9]+$/ =~ params[:part]
    part = params[:part].to_i
    raise RequestError.new(:bad_part, "Content incorrect") if f.content.nil?
    raise RequestError.new(:bad_part, "Part number too high") if part > ( f.content.size / XFile.part_size )
    data = request.body.read
    part_size = (part == f.content.size / XFile.part_size ? f.content.size % XFile.part_size : XFile.part_size)
    raise RequestError.new(:bad_part, "Size of part incorrect") unless part_size == data.length
    cypher = WodaCrypt.new
    cypher.encrypt
    cypher.key = f.content.crypt_key.from_hex
    cypher.iv = WodaHash.digest(params[:part])
    bucket = Storage['woda-files']
    obj = bucket.create("#{f.content.content_hash}/#{params[:part]}", data: (cypher.update(data) + cypher.final), content_type: 'octet-stream')
    @result = { success: true }
  end

  ##
  # Method to specify that a file has been fully uploaded
  def upload_success
    file = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_param, "Can't upload data to a folder") if f.folder
    file.uploaded = true
    update_and_save file
    @result = { success: true }
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
    file = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_param, "Can't delete the root folder") if file == session[:user].x_files.first
    file.delete_content
    update_and_delete file
    @result = { success: true }
  end

  ##
  # Get the specific file corresponding to the ID given in parameters
  def get
    f = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless f
    raise RequestError.new(:bad_param, "Can't get a folder") if f.folder
    raise RequestError.new(:bad_part, "Content incorrect") if f.content.nil?
    raise RequestError.new(:file_not_uploaded, "File not completely uploaded") unless f.uploaded
    key = "#{f.content.content_hash}/#{params[:part]}"
    raise RequestError.new(:no_bucket, "Bucket not found") if Storage['woda-files'].nil?
    raise RequestError.new(:no_key, "Key path not found") if (Storage.use_aws ? Storage['woda-files'][key].exists? == false : Storage['woda-files'][key].nil? )
    file = Storage['woda-files'][key].read()
    if params[:part].to_i == 0 then
      f.downloads += 1
      f.save
    end
    cypher = WodaCrypt.new
    cypher.decrypt
    cypher.key = f.content.crypt_key.from_hex
    cypher.iv = WodaHash.digest(params[:part])
    @result = { data: cypher.update(file) + cypher.final, success: true }
  end

  ##
  # Method to get the timestamp of the last modification of the user's file list
  def last_update
    folder = ( params[:id].nil? ? session[:user].x_files.first : session[:user].x_files.get(params[:id]) )
    raise RequestError.new(:file_not_found, "Folder not found") if folder.nil?    
    @result =  { last_update: folder.last_update, success: true }
  end

end
