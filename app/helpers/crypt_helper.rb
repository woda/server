require 'openssl'
require 'app/helpers/string'

class WodaCrypt < OpenSSL::Cipher::AES256
  def initialize
    super :CBC
  end

  KEY_REGEXP = hex_regex WodaCrypt.new.random_key.to_hex.length
  IV_REGEXP = hex_regex WodaCrypt.new.random_iv.to_hex.length
end
