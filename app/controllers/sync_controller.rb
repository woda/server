# -*- coding: utf-8 -*-
require 'time'
require 'openssl'
require 'digest/sha1'
require 'tempfile'

class SyncController < ApplicationController
  before_filter :require_login

  before_filter Proc.new { |c| c.check_params :filename, :content_hash, :size }, :only => [:put, :change]
  before_filter Proc.new { |c| c.check_params :id, :part }, :only => [:upload_part, :get]

  def put
    # TODO deal with: existing file not content
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
    f.update_and_save
    session[:user].save
  end

  def upload_part
    f = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless f
    raise RequestError.new(:bad_part, "\"#{params[:part]}\" isn't an acceptable part name") unless /^[0-9]+$/ =~ params[:part]
    part = params[:part].to_i
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
    file.update_and_save
    @result = { success: true }
  end

  def change
    delete
    put
  end

  def delete
    file = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    destroy_content = nil
    if XFile.count(content_hash: file.content) <= 1 then
     destroy_content = file.content
    end
    file.destroy!
    destroy_content.destroy! if destroy_content
    @result = { success: true }
  end

  def get
    f = session[:user].x_files.get(params[:id])
    while !f.content do
      f = f.x_file
    end
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
