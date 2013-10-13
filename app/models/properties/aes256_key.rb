require 'dm-core'
require 'app/helpers/woda_crypt'

module DataMapper
  class Property
  	##
  	# A class meant to handle an AES-256 key property in models
    class AES256Key < String
      length WodaCrypt.new.random_key.to_hex.length + 1
      format WodaCrypt::KEY_REGEXP
    end
  end
end
