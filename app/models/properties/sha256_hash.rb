require 'dm-core'
require 'lib/helpers/hash_digest'
require 'securerandom'

module DataMapper
  class Property
    class SHA256Hash < String
      length WodaHash.digest("").to_hex.length + 1
      format WodaHash::DIGEST_REGEXP

      def self.generate_random
        SecureRandom.hex(256 / 8)
      end
    end
    class SHA256Salt < SHA256Hash
    end
  end
end
