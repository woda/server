require 'digest'
require 'helpers/string_ext.rb'

class WodaHash < OpenSSL::Digest::SHA256
  DIGEST_REGEXP = hex_regex WodaHash.digest("").to_hex.length
end
