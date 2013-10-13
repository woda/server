require 'openssl'
<<<<<<< HEAD:app/helpers/crypt_helper.rb
require 'app/helpers/string'
=======
require 'app/helpers/string_ext'
>>>>>>> 8b594bc8d4926c9cdf38993960fcd9ca656fa403:app/helpers/woda_crypt.rb

class WodaCrypt < OpenSSL::Cipher::AES256
  def initialize
    super :CBC
  end

  KEY_REGEXP = hex_regex WodaCrypt.new.random_key.to_hex.length
  IV_REGEXP = hex_regex WodaCrypt.new.random_iv.to_hex.length
end
