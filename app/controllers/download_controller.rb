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
  # Get the specific file corresponding to the ID given in parameters
  def get
    file = XFile.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_access, "No access") unless file.users.include? session[:user]
    raise RequestError.new(:bad_param, "Can't get a folder") if file.folder
    raise RequestError.new(:bad_part, "Content incorrect") if file.content.nil?
    raise RequestError.new(:file_not_uploaded, "File not completely uploaded") unless file.uploaded
    key = "#{file.content.content_hash}/#{params[:part]}"
    raise RequestError.new(:no_bucket, "Bucket not found") if Storage['woda-files'].nil?
    raise RequestError.new(:no_key, "Key path not found") if (Storage.use_aws ? Storage['woda-files'][key].exists? == false : Storage['woda-files'][key].nil? )
    data = Storage['woda-files'][key].read()
    if params[:part].to_i == 0 then
      file.downloads += 1
      file.save
    end
    cypher = WodaCrypt.new
    cypher.decrypt
    cypher.key = file.content.crypt_key.from_hex
    cypher.iv = WodaHash.digest(params[:part])
    @result = cypher.update(data) + cypher.final
  end

  ##
  # Download a file from a direct link
  def ddl
    files = WFile.all(uuid: params[:uuid])
    raise RequestError.new(:internal_error, "Double UUID, please contact your administrator") if files.count > 1
    file = files.first
    raise RequestError.new(:bad_param, "File not uploaded") unless file.uploaded

    filedata = ''
    parts = (file.content.size / PART_SIZE) + (!!(file.content.size % PART_SIZE) ? 1 : 0)
    parts.times do |part|
      key = "#{file.content.content_hash}/#{part}"
      raise RequestError.new(:no_bucket, "Bucket not found") if Storage['woda-files'].nil?
      raise RequestError.new(:no_key, "Key path not found") if (Storage.use_aws ? Storage['woda-files'][key].exists? == false : Storage['woda-files'][key].nil? )
      data = Storage['woda-files'][key].read()
      if part == 0 then
        file.downloads += 1
        file.save
      end
      cypher = WodaCrypt.new
      cypher.decrypt
      cypher.key = file.content.crypt_key.from_hex
      cypher.iv = WodaHash.digest(part.to_s)
      filedata += cypher.update(data) + cypher.final
    end
    send_data(filedata, filename: file.name)
  end

end
