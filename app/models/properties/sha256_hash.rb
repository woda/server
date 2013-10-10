require 'dm-core'
require 'app/helpers/hash_digest'
require 'securerandom'

module DataMapper
  class Property
    ##
    # A class meant to handle an SHA-256 property in models
    class SHA256Hash < String
      length WodaHash.digest("").to_hex.length + 1
      format WodaHash::DIGEST_REGEXP

      ##
      # Generate a proper random string for that purpose
      def self.generate_random
        SecureRandom.hex(256 / 8)
      end
    end
    class SHA256Salt < SHA256Hash
    end
  end
end
