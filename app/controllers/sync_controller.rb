require 'time'
require 'openssl'
require 'digest/sha1'
require 'tempfile'

BASE_URL='https://ec2-54-242-98-168.compute-1.amazonaws.com:3000'

class SyncController < ApplicationController
  before_filter :require_login
  before_filter { |c| c.check_params :filename }
  before_filter Proc.new { |c| c.check_params :content_hash, :size }, :only => [:put, :change]
  before_filter Proc.new { |c| c.check_params :part }, :only => [:upload_part]
  before_filter Proc.new { |c| c.check_params :part }, :only => [:get2]
  before_filter Proc.new { |c| c.check_params :status }, :only => [:set_public_status]
  before_filter Proc.new { |c| c.check_params :user, :foreign_filename }, :only => [:sync_public]

  def put
    current_content = Content.first content_hash: params['content_hash']
    f = session[:user].get_file(params['filename'].split('/'), create: true)
    f.last_modification_time = DateTime.now
    set_content_files = [f]
#TODO: this needs to be uncommented
    # If it took more than 24 hours to upload the file, we just start over
#    if current_content && current_content.start_upload != 0 && current_content.start_upload < (Time.now.utc.to_i - 24 * 3600) && XFile.find(content: current_content)
#      set_content_files += XFile.find(content: current_content).to_a
#      current_content = nil
#      delete_s3_file params['content_hash']
#    end
    if current_content
      @result = {success: true, need_upload: false, file: f}
    else
      current_content = Content.new(content_hash: params['content_hash'],
                                    size: params['size'].to_i,
                                    crypt_key: WodaCrypt.new.random_key.to_hex,
                                    init_vector: WodaCrypt.new.random_iv.to_hex,
                                    start_upload: Time.now.utc.to_i, file_type: 'none')
      # TODO: not hardcode part size
      @result = {success: true, need_upload: true, file: f, part_size: 5 * 1024 * 1024}
      current_content.save
    end
    set_content_files.each { |file| file.content = current_content }
    session[:user].save
    set_content_files.each { |file| file.save }
  end

  # TODO: more security checks
  def upload_part
    f = session[:user].get_file(params['filename'].split('/'), create: false)
    raise RequestError.new(:file_not_found, "File not found") unless f
    raise RequestError.new(:bad_part, "\"#{params['part']}\" isn't an acceptable part name") unless /^[0-9]+$/ =~ params['part']
    part = params['part'].to_i
    raise RequestError.new(:bad_part, "Part number too high") if part > f.content.size / (5*1024*1024)
    data = request.body.read
    part_size = (part == f.content.size / (5*1024*1024) ? f.content.size % (5*1024*1024) : (5*1024*1024))
    raise RequestError.new(:bad_part, "Size of part incorrect") unless part_size == data.length
    bucket = Storage['woda-files']
    obj = bucket.create("#{f.content.content_hash}/#{params['part']}",
                        :data => data,
                        :content_type => 'octet-stream',
                        :server_side_encryption => :aes256,
                        :encryption_key => f.content.crypt_key.from_hex)
    @result = {success:true}
  end

  def upload_success
    content = Content.first content_hash: params['key']
    if content
      content.start_upload = 0
      content.save
      @result = {success: true}
    else
      @result = {success: false}
    end
  end

  def change
    f = session[:user].get_file(params['filename'].split('/'))
    if f.read_only
      @result = {success: false}
      return
    end
    delete
    put
  end

  def delete
    f = session[:user].get_file(params['filename'].split('/'))
    raise RequestError.new(:file_not_found, "File not found") unless f
    destroy_content = nil
#TODO: this needs to be uncommented
#    if XFile.count(contents: f.contents) <= 1 then
#      destroy_content = f.content
#    end
    f.destroy!
    destroy_content.destroy! if destroy_content
    @result = {success: true}
  end

  def set_public_status
    f = session[:user].get_file(params['filename'].split('/'))
    raise RequestError.new(:file_not_found, "File not found") unless f
    f.is_public = (params['status'] == "true")
    f.save
    @result = {success: true}
  end

  def public_status
    f = session[:user].get_file(params['filename'].split('/'))
    raise RequestError.new(:file_not_found, "File not found") unless f
    @result = {success: true, status: f.is_public}
  end

  def sync_public
    u2 = User.first login: params['user']
    raise RequestError.new(:bad_user, "User not found") unless u2
    f2 = u2.get_file(params['foreign_filename'].split('/'))
    raise RequestError.new(:file_not_found, "File not found") unless f2 && f2.is_public
    f = session[:user].get_file(params['filename'].split('/'), :create => true)
    f.x_file = f2
    f.last_modification_time = DateTime.now
    session[:user].save
    f.save
    @result = {success: true}
  end

  def get2
    f = session[:user].get_file(params['filename'].split('/'))
    while !f.content do
      f = f.x_file
    end
    raise RequestError.new(:file_not_found, "File not found") unless f
    file = Storage['woda-files']["#{f.content.content_hash}/#{params['part']}"].read(:encryption_key => f.content.crypt_key.from_hex)
    if params['part'].to_i == 0 then
      f.downloads += 1
      f.save
    end
    @result = file
  end
end
