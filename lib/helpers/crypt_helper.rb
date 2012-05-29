require 'openssl'
require 'helpers/string_ext'

class WodaCrypt < OpenSSL::Cipher::AES256
  def initialize
    super :CBC
  end

  KEY_REGEXP = hex_regex WodaCrypt.new.random_key.to_hex.length
  IV_REGEXP = hex_regex WodaCrypt.new.random_key.to_hex.length
end
