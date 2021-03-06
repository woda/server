# -*- coding: utf-8 -*-
require 'time'
require 'openssl'
require 'digest/sha1'
require 'tempfile'

class SyncController < ApplicationController
  before_filter :require_login, :only => [:create_folder, :put, :change, :upload_part, :get, :delete, :needed_parts, :synchronize]

  before_filter Proc.new { |c| c.check_params :filename }, :only => [:create_folder]
  before_filter Proc.new { |c| c.check_params :filename, :content_hash, :size }, :only => [:put, :change]
  before_filter Proc.new { |c| c.check_params :id, :part }, :only => [:upload_part, :get]
  before_filter Proc.new { |c| c.check_params :id}, :only => [:delete, :needed_parts, :synchronize]
  before_filter Proc.new { |c| c.check_params :uuid}, :only => [:download]

  ##
  # Returns the model, useful for ApplicationController.
  def model
    nil
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
        item.update_and_save
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
    folder = WFolder.create(session[:user], params[:filename])
    folder.update_and_save
    @result = { folder: folder.description, success: true }
  end

  ##
  # Create a file and return it. 
  def put
    raise RequestError.new(:bad_param, "Parameter 'filename' is not valid") if params[:filename].nil? || params[:filename].empty?
    raise RequestError.new(:bad_param, "Parameter 'content_hash' is not valid") if params[:content_hash].nil? || params[:content_hash].empty?
    raise RequestError.new(:bad_param, "Parameter 'size' is not valid") if params[:size].nil? || params[:size].empty? || params[:size].to_i <= 0
    raise RequestError.new(:bad_param, "Current account doesn't have enough to space to store this file") unless session[:user].can_add_file_size(params[:size].to_i)
    
    # if file already exist...
    XFile.all(user: session[:user], name: params[:filename]).each do |file|
      # error if already uploaded
      raise RequestError.new(:bad_param, "File already exists") if file.uploaded
      # otherwise return needed parts
      params[:id] = file.id
      needed_parts
      return 
    end

    # find if the content already exist
    current_content = Content.first content_hash: params[:content_hash]
    already_uploaded = (current_content ? current_content.uploaded : false)
    # create a WFile
    file = WFile.create(session[:user], params[:filename])
    # if already uploaded do nothing
    if current_content && already_uploaded
      file.uploaded = true
      @result = { success: true, uploaded: true }
    # otherwise create a content, set the file as non-uploaded and return everything
    else
      current_content = Content.create(params[:content_hash], params[:size].to_i) if current_content.nil?
      @result = { success: true, uploaded: false, needed_parts: current_content.needed_parts, part_size: PART_SIZE }
    end
    # set the current content to the current file
    file.content = current_content
    # save the file and its parents
    file.update_and_save
    session[:user].add_file_size current_content.size
    session[:user].save
    @result.merge!({ file: file.description })
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
    uploaded = complete_upload(file.content, part)
    @result = { success: true, needed_parts: file.content.needed_parts, uploaded: uploaded }
  end

  ##
  # Method to get the content parts that still need to be uploaded
  def needed_parts
    file = XFile.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_access, "No access") unless file.users.include? session[:user]
    raise RequestError.new(:bad_param, "Can't upload data to a folder") if file.folder
    raise RequestError.new(:no_content, "File content found") if file.content.nil?
    @result = { success: true, needed_parts: file.content.needed_parts, uploaded: file.uploaded, file: file.description(session[:user]) }
  end

  ##
  # Delete and recreate a file with the given parameters
  def change
    #TODO allow write access for shared files
    file = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_access, "No write access") if file.user != session[:user]
    delete
    put
  end

  ##
  # Delete a file
  def delete
    shared_file = session[:user].x_files_shared_to_me.get(params[:id])
    if shared_file then
      SharedToMeAssociation.all(x_file_id: shared_file.id, user_id: session[:user].id).destroy!
    else
      file = WFile.get(params[:id])
      raise RequestError.new(:file_not_found, "File not found") unless file
      raise RequestError.new(:bad_access, "No access") unless file.users.include? session[:user]
      raise RequestError.new(:bad_param, "Can't delete the root folder") if file.id == session[:user].root_folder.id
      (file.folder ? WFolder.get(params[:id]) : file).update_and_delete session[:user]
    end
    @result = { success: true }
  end

  ##
  # Synchronize a public file into the main folder
  def synchronize
    file = WFile.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_access, "No access") unless file.public?
    raise RequestError.new(:bad_param, "Can't synchronize a folder") if file.folder
    raise RequestError.new(:bad_param, "File not uploaded") unless file.uploaded
    raise RequestError.new(:bad_param, "File or folder already synchronized") if session[:user].x_files.get(params[:id])
    
    file = WFile.create_from_origin(session[:user], file) if (!params[:link] || params[:link] == "false")
    file = WFile.link_from_origin(session[:user], file) if (params[:link] && params[:link] == "true")

    file.update_and_save
    @result = { success: true, file: file.description(session[:user]) }
    session[:user].save
  end

end
