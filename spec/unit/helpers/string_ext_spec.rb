require 'spec_helper'

require_corresponding __FILE__

describe String, :unit do
  it "should be able to be converted to and from hex" do
    s = "uhtathbxteu.crcr40y34ych3"
    s.to_hex.from_hex.should be == s
  end

  it "should be converted to a purely hexadecimal string using to_hex" do
    hex = "ahutehththth234cgc".to_hex
    hex_regex(hex.length).should be =~ hex
  end
end
