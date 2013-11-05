# -*- coding: utf-8 -*-
require 'time'
require 'openssl'
require 'digest/sha1'
require 'tempfile'

class SyncController < ApplicationController
  before_filter :require_login

  before_filter Proc.new { |c| c.check_params :filename, :content_hash, :size }, :only => [:put, :change]
  before_filter Proc.new { |c| c.check_params :id, :part }, :only => [:upload_part, :get]

  ##
  # Update the given file, save it and update its parent recursively 
  def update_and_save file
    file.last_update = Time.now
    file.save
    parent = session[:user].x_files.get file.x_file_id
    update_and_save parent if parent
  end

  ##
  # Update the parent of the given file and remove its children and itself
  def update_and_delete file
    parent = session[:user].x_files.get file.x_file_id
    update_and_save parent if parent
    file.delete
  end

  ##
  # Creates and return a new folder
  def create_folder
    folder = session[:user].create_folder( params[:filename] )
    raise RequestError.new(:folder_not_created, "Folder not created") if folder.nil?
    update_and_save folder
    @result = { folder: folder.description, success: true }
  end

  def put
    # TODO deal with: existing file not content
    return create_folder if params[:folder] == "true"

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

  def upload_part
    f = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless f
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

  def upload_success
    file = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    file.uploaded = true
    update_and_save file
    @result = { success: true }
  end

  def change
    delete
    put
  end

  def delete
    file = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_param, "Can't delete root folder") if file.id == session[:user].x_files.first.id
    file.delete_content
    update_and_delete file
    @result = { success: true }
  end

  def get
    f = session[:user].x_files.get(params[:id])
    raise RequestError.new(:bad_part, "Content incorrect") if f.nil?
    key = "#{f.content.content_hash}/#{params[:part]}"
    raise RequestError.new(:file_not_found, "File not found") unless f
    raise RequestError.new(:no_bucket, "Bucket not found") if Storage['woda-files'] == nil
    raise RequestError.new(:no_key, "Key path not found") if Storage['woda-files'][key] == nil
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

  def last_update
    folder = ( params[:id].nil? ? session[:user].x_files.first : session[:user].x_files.get(params[:id]) )
    raise RequestError.new(:file_not_found, "Folder not found") if folder.nil?    
    @result =  { last_update: folder.last_update, success: true }
  end

end
