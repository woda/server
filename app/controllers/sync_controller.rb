require 'time'
require 'openssl'
require 'digest/sha1'

BASE_URL='https://ec2-54-242-98-168.compute-1.amazonaws.com:3000'

class SyncController < ApplicationController
 	before_filter :require_login
 	before_filter { |c| c.check_params :filename }
 	before_filter Proc.new { |c| c.check_params :content_hash, :size }, :only => [:put, :change]
 	before_filter Proc.new { |c| c.check_params :part, :data }, :only => [:upload_part]
 	before_filter Proc.new { |c| c.check_params :part }, :only => [:get2]

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
 			# TODO: not hardcode part size
			@result = {success: true, need_upload: true, file: f, part_size: 5 * 1024 * 1024}
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
		part_size = (part == f.content.size / (5*1024*1024) ? f.content.size % (5*1024*1024) : (5*1024*1024))
		raise RequestError.new(:bad_part, "Size of part incorrect") unless part_size == params['data'].length
		cypher = WodaCrypt.new
		cypher.encrypt
		cypher.iv = f.content.init_vector
		cypher.key = f.content.crypt_key
		s3 = AWS::S3.new
		bucket = s3.buckets['woda-files']
		obj = bucket.objects.create("#{f.content.content_hash}/#{params['part']}",
			:data => cypher.update(params['data']) + cypher.final,
			:content_type => 'octet-stream')
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
		file = s3.buckets['woda-files'].objects["#{f.content.content_hash}/#{params['part']}"].read
		cypher = WodaCrypt.new
		cypher.decrypt
		cypher.iv = f.content.init_vector
		cypher.key = f.content.crypt_key
		@result = cypher.update(file) + cypher.final
	end
end
