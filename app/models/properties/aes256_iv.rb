require 'dm-core'
require 'app/helpers/crypt_helper'

module DataMapper
  class Property
    class AES256Iv < String
      length WodaCrypt.new.random_iv.to_hex.length + 1
      format WodaCrypt::IV_REGEXP
    end
  end
end
