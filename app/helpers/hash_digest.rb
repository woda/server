require 'digest'
require 'app/helpers/string.rb'

class WodaHash < OpenSSL::Digest::SHA256
  DIGEST_REGEXP = hex_regex WodaHash.digest("").to_hex.length
end
