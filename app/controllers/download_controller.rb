# -*- coding: utf-8 -*-
require 'time'
require 'openssl'
require 'digest/sha1'
require 'tempfile'

class DownloadController < ApplicationController
  
  before_filter :require_login, :only => [:get]

  before_filter Proc.new { |c| c.check_params :id, :part }, :only => [:get]
  before_filter Proc.new { |c| c.check_params :uuid}, :only => [:download]

  ##
  # Uncrypt data for a file and a part
  def uncrypt file, data, part
    cypher = WodaCrypt.new
    cypher.decrypt
    cypher.key = file.content.crypt_key.from_hex
    cypher.iv = WodaHash.digest(part.to_s)
  cypher.update(data) + cypher.final
  end

  ##
  # Retrieve data from bucket
  def retrieve file, part
    key = "#{file.content.content_hash}/#{part}"
    raise RequestError.new(:no_bucket, "Bucket not found") if Storage['woda-files'].nil?
    if (Storage.use_aws ? Storage['woda-files'][key].exists? == false : Storage['woda-files'][key].nil? ) then
      raise RequestError.new(:no_key, "Key path not found")
    end
    data = Storage['woda-files'][key].read()
    if part == 0 then
      file.downloads += 1
      file.save
    end
    uncrypt(file, data, part)
  end

  ##
  # Retrieve an entire file from bucket
  def full_retrieve file
    filedata = ''
    parts = (file.content.size / PART_SIZE) + (!!(file.content.size % PART_SIZE) ? 1 : 0)
    parts.times do |part|
      filedata += retrieve(file, part)
    end
    filedata
  end

  ##
  # Get the specific file corresponding to the ID given in parameters
  def get
    file = XFile.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_access, "No access") unless file.users.include? session[:user]
    raise RequestError.new(:bad_param, "Can't get a folder") if file.folder
    raise RequestError.new(:bad_part, "Content incorrect") if file.content.nil?
    raise RequestError.new(:file_not_uploaded, "File not completely uploaded") unless file.uploaded

    @result = retrieve(file, params[:part].to_i) if (!params[:direct] || params[:direct] != "true")
  	send_data(full_retrieve(file), filename: file.name) if (params[:direct] == "true")
  end

  ##
  # Download a file from a direct link
  def ddl
    files = WFile.all(uuid: params[:uuid])
    file = files.first
    raise RequestError.new(:bad_param, "File not found") if !file || !files || files.count == 0
    raise RequestError.new(:internal_error, "Double UUID, please contact your administrator") if files.count > 1
    raise RequestError.new(:bad_param, "File not uploaded") unless file.uploaded

    send_data(full_retrieve(file), filename: file.name)
  end

end
