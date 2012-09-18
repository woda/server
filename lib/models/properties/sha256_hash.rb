require 'dm-core'
require 'helpers/hash_digest'
require 'active_support/secure_random'

module DataMapper
  class Property
    class SHA256Hash < String
      length WodaHash.digest("").to_hex.length + 1
      format WodaHash::DIGEST_REGEXP

      def self.generate_random
        SHA256Hash.new ActiveSupport::SecureRandom.hex(256 / 8)
      end
    end
    SHA256Salt = SHA256Hash
  end
end
