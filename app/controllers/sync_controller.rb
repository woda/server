require 'time'
require 'openssl'
require 'digest/sha1'

class SyncController < ApplicationController
 	before_filter :require_login
 	before_filter { |c| c.check_params :filename }
 	before_filter Proc.new { |c| c.check_params :content_hash, :size }, :only => [:put, :change]

 	def put
 		current_content = Content.first content_hash: params['content_hash']
 		f = session[:user].get_file(params['filename'].split('/'), create: true)
 		f.last_modification_time = DateTime.now
 		set_content_files = [f]
 		# If it took more than 24 hours to upload the file, we just start over
 		if current_content && current_content.start_upload != 0 && current_content.start_upload < (Time.now.utc.to_i - 24 * 3600)
 			set_content_files += WFile.find(content: current_content)
 			current_content = nil
 			delete_s3_file params['content_hash']
 		end
 		if current_content
 			@result = {success: true, need_upload: false, file: f}
 		else
 			current_content = Content.new(content_hash: params['content_hash'],
 				size: params['size'],
 				crypt_key: WodaCrypt.new.random_key.to_hex,
 				init_vector: WodaCrypt.new.random_iv.to_hex,
 				start_upload: Time.now.utc.to_i)
			policy = {
				'expiration' => (Time.now.utc + 1800).iso8601,
				'conditions' => [
					{'bucket' => 'woda-files'},
					{'key' => params['content_hash']},
					{'acl' => 'private'},
					{'success_action_redirect' => '#{BASE_URL}/sync/upload_success'},
					['content-length-range', params['size'], params['size']],
					{'Content-Type' => 'application/octet-stream'},
				]
			}
			policy_64 = Base64.encode64(policy.to_json).gsub("\n","")
			signature = Base64.encode64(
    			OpenSSL::HMAC.digest(
    			    OpenSSL::Digest::Digest.new('sha1'), 
        			AWS_SECRET, policy_64)
			    ).gsub("\n","")
			@result = {success: true, need_upload: true, file: f, policy: policy,
				signature: signature, key: current_content.crypt_key,
				iv: current_content.init_vector}
		end
		set_content_files.each { |file| file.content = current_content }
 		session[:user].save
 		set_content_files.each { |file| file.save }
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
		delete
		put
	end

	def delete
		f = session[:user].get_file(params['filename'].split('/'))
		raise RequestError.new(:file_not_found, "File not found") unless f
		destroy_content = nil
		if XFile.count(content: f.content) <= 1 then
                  destroy_content = f.content
		end
		f.destroy!
		destroy_content.destroy! if destroy_content
		@result = {success: true}
	end

	def get2
		f = session[:user].get_file(params['filename'].split('/'))
		raise RequestError.new(:file_not_found, "File not found") unless f
		s3 = AWS::S3.new
		@result = {url: s3.buckets['woda-files'].objects[f.content.content_hash].url_for(:read).to_s,
		  key: f.content.crypt_key, iv: f.content.init_vector}
	end
end
