# -*- coding: utf-8 -*-
require 'time'
require 'openssl'
require 'digest/sha1'
require 'tempfile'
require 'securerandom'

class SyncController < ApplicationController
  before_filter :require_login

  before_filter Proc.new { |c| c.check_params :filename }, :only => [:upload_success, :delete]
  before_filter Proc.new { |c| c.check_params :content_hash, :size }, :only => [:put, :change]
  before_filter Proc.new { |c| c.check_params :part }, :only => [:upload_part, :get]
  before_filter Proc.new { |c| c.check_params :user, :foreign_filename }, :only => [:sync_public]

  def put
    # TODO deal with: existing file not content
    current_content = Content.first content_hash: params['content_hash']
    f = session[:user].get_file(params['filename'].split('/'), create: true)
    if current_content
      f.uploaded = true
      f.save
      @result = {success: true, need_upload: false, file: f.description}
    else
      current_content = Content.new(content_hash: params['content_hash'],
                                    size: params['size'].to_i,
                                    crypt_key: WodaCrypt.new.random_key.to_hex)
      @result = { success: true, need_upload: true, file: f.description, part_size: XFile.part_size }
      current_content.save
    end
    f.content = current_content
    f.update_and_save
    # f.save
    session[:user].save
  end

  def upload_part
    f = session[:user].get_file(params['filename'].split('/'), create: false)
    raise RequestError.new(:file_not_found, "File not found") unless f
    raise RequestError.new(:bad_part, "\"#{params['part']}\" isn't an acceptable part name") unless /^[0-9]+$/ =~ params['part']
    part = params['part'].to_i
    raise RequestError.new(:bad_part, "Part number too high") if part > ( f.content.size / XFile.part_size )
    data = request.body.read
    part_size = (part == f.content.size / XFile.part_size ? f.content.size % XFile.part_size : XFile.part_size)
    raise RequestError.new(:bad_part, "Size of part incorrect") unless part_size == data.length
    cypher = WodaCrypt.new
    cypher.encrypt
    cypher.key = f.content.crypt_key.from_hex
    cypher.iv = WodaHash.digest(params['part']) # Note: maybe concatenate init_vector here (before WodaHash)
    bucket = Storage['woda-files']
    obj = bucket.create("#{f.content.content_hash}/#{params['part']}", :data => cypher.update(data) + cypher.final, content_type: 'octet-stream')
    @result = { success:true }
  end

  def upload_success
    file = session[:user].get_file(params['filename'].split('/'))
    raise RequestError.new(:file_not_found, "File not found") unless file
    file.uploaded = true
    file.update_and_save
    @result = { success: true }
  end

  def change
    file = session[:user].get_file(params['filename'].split('/'))
    delete
    put
  end

  def delete
    file = session[:user].get_file(params['filename'].split('/'))
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
    f = session[:user].get_file(params['filename'].split('/'))
    while !f.content do
      f = f.x_file
    end
    key = "#{f.content.content_hash}/#{params['part']}"
    raise RequestError.new(:file_not_found, "File not found") unless f
    raise RequestError.new(:no_bucket, "Bucket not found") if Storage['woda-files'] == nil
    raise RequestError.new(:no_key, "Key path not found") if Storage['woda-files'][key] == nil
    file = Storage['woda-files'][key].read()
    if params['part'].to_i == 0 then
      f.downloads += 1
      f.save
    end
    cypher = WodaCrypt.new
    cypher.decrypt
    cypher.key = f.content.crypt_key.from_hex
    cypher.iv = WodaHash.digest(params['part']) # Note: maybe concatenate init_vector here (before WodaHash
    @result = { file: cypher.update(file) + cypher.final, success: true }
  end

  def link
    f = session[:user].get_file(params['filename'].split('/'))
    raise RequestError.new(:file_not_found, "File not found") unless f
    f.uuid = SecureRandom::uuid unless f.uuid
    f.save
    @result = { success: true, link: "#{BASE_URL}/app_dev.php/fs-file/#{f.uuid}" }
  end

  def last_update
    aim = params[:folder]
    folder = session[:user].get_folder((aim.nil? ? '' : aim).split('/'))
    raise RequestError.new(:file_not_found, "Folder not found") if folder.nil?    
    @result =  { last_update: folder.last_update, success: true }
  end

  # useless method
  def sync_public
    u2 = User.first login: params['user']
    raise RequestError.new(:bad_user, "User not found") unless u2
    f2 = u2.get_file(params['foreign_filename'].split('/'))
    raise RequestError.new(:file_not_found, "File not found") unless f2 && f2.public
    file = session[:user].get_file(params['filename'].split('/'), create: true)
    file.x_file = f2
    file.save
    session[:user].save
    @result = { success: true }
  end
end
