require 'dm-core'
require 'helpers/crypt_helper'

module DataMapper
  class Property
    class AES256Key < String
      length WodaCrypt.new.random_key.to_hex.length + 1
      format WodaCrypt::KEY_REGEXP
    end
  end
end
