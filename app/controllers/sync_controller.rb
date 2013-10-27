require 'time'
require 'openssl'
require 'digest/sha1'
require 'tempfile'

# BASE_URL='https://ec2-54-242-98-168.compute-1.amazonaws.com:3000'

class SyncController < ApplicationController
  before_filter :require_login
  # before_filter { |c| c.check_params :filename }

  # before_filter Proc.new { |c| c.check_params :filename }, :only => [:upload_success, :delete]
  before_filter Proc.new { |c| c.check_params :content_hash, :size }, :only => [:put, :change]
  before_filter Proc.new { |c| c.check_params :part }, :only => [:upload_part, :get]
  before_filter Proc.new { |c| c.check_params :user, :foreign_filename }, :only => [:sync_public]

  def put
    current_content = Content.first content_hash: params['content_hash']
    f = session[:user].get_file(params['filename'].split('/'), create: true)
    set_content_files = [f]
#TODO: this needs to be uncommented
    # If it took more than 24 hours to upload the file, we just start over
#    if current_content && current_content.start_upload != 0 && current_content.start_upload < (Time.now.utc.to_i - 24 * 3600) && XFile.find(content: current_content)
#      set_content_files += XFile.find(content: current_content).to_a
#      current_content = nil
#      delete_s3_file params['content_hash']
#    end
    if current_content
      f.uploaded = true
      f.save
      @result = {success: true, need_upload: false, file: f}
    else
      current_content = Content.new(content_hash: params['content_hash'],
                                    size: params['size'].to_i,
                                    crypt_key: WodaCrypt.new.random_key.to_hex,
                                    start_upload: Time.now.utc.to_i, file_type: 'none')      
      @result = {success: true, need_upload: true, file: f, part_size: XFile.part_size }
      current_content.save
    end
    set_content_files.each { |file| file.content = current_content }
    session[:user].save
    set_content_files.each { |file| file.save }
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
    bucket = Storage['woda-files']
    obj = bucket.create("#{f.content.content_hash}/#{params['part']}", data: data, content_type: 'octet-stream')
    @result = { success:true }
  end

  def upload_success
    file = session[:user].get_file(params['filename'].split('/'))
    raise RequestError.new(:file_not_found, "File not found") unless file
    file.uploaded = true
    file.save
    @result = { success: true }
  end

  # TODO test
  def change
    file = session[:user].get_file(params['filename'].split('/'))
    raise RequestError.new(:read_only, "File is read-only") if file.read_only
    delete
    put
    # @result = { success: true }
  end

# TODO test
  def delete
    file = session[:user].get_file(params['filename'].split('/'))
    raise RequestError.new(:file_not_found, "File not found") unless file
    destroy_content = nil
    if XFile.count(contents: file.contents) <= 1 then
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
    @result = { file: f, success: true }
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
