require 'time'
require 'openssl'
require 'digest/sha1'

class SyncController < ApplicationController
 	before_filter :require_login
 	before_filter { |c| c.check_params :filename }
 	before_filter { |c| c.check_params :content_hash, :size }, :only => [:put, :change]

 	def put
 		current_content = Content.first content_hash: params['content_hash']
 		f = WFile.new(filename: params['filename'], last_modification_time: DateTime.now)
 		set_content_files = [f]
 		# If it took more than 24 hours to upload the file, we just start over
 		if current_content.start_upload != 0 && current_content.start_upload < (time.now.utc.to_i - 24 * 3600)
 			set_content_files += WFile.find(content: current_content)
 			current_content = nil
 			delete_s3_file params['content_hash']
 		end
 		if current_content
 			@result = {success: true, need_upload: false, file: f}
 		else
 			current_content = content.new(content_hash: params['content_hash'],
 				size: params['size'],
 				crypt_key: WodaCrypt.new.random_key.to_hex,
 				init_vector: WodaCrypt.new.random_iv.to_hex,
 				start_upload: time.now.utc.to_i)
			policy = {
				'expiration' => (Time.now.utc + 1800).iso8601,
				'conditions' => [
					{'bucket' => 'woda-files'},
					{'key' => params['content_hash']},
					{'acl' => 'private'},
					{'success_action_redirect' => '#{BASE_URL}/sync/upload_success'},
					['content-length-range', params['size'], params['size']]
					{'Content-Type' => 'application/octet-stream'},
				]
			}
			policy_64 = Base64.encode64(policy.to_json).gsub("\n","")
			signature = Base64.encode64(
    			OpenSSL::HMAC.digest(
    			    OpenSSL::Digest::Digest.new('sha1'), 
        			aws_secret_key, policy_64)
			    ).gsub("\n","")
			@result = {success: true, need_upload: true, file: f, policy: policy,
				signature: signature, key: current_content.crypt_key,
				iv: current_content.init_vector}
		end
		set_content_files.each { |file| file.content = current_content }
 		session[:user].files << f
 		session[:user].save
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

	def 
end
