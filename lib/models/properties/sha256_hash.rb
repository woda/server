require 'dm-core'
require 'helpers/hash_digest'

module DataMapper
  class Property
    class SHA256Hash < String
      length WodaHash.digest("").to_hex.length + 1
      format WodaHash::DIGEST_REGEXP
    end
  end
end
