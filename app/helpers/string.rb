class String
  def to_hex
    unpack("H*")[0]
  end

  def from_hex
    [self].pack("H*")
  end
end

def hex_regex size
  /^[0-9a-fA-F]{#{size}}$/
end
