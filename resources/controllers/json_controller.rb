require 'json'

class JsonController
  attr_accessor :inital_string, :parsed_string

  def initialize(string)
    @inital_string = string
    @parsed_string = JSON.parse(string)
  end
  
  def error?
    if @parsed_string['status'] == "ko"
      true
    else
      false
    end
  end

  def get(what)
    @parsed_string[what]
  end
  
  def nested
    @parsed_string['data']
  end

  def self.generate(*args)
    JSON.generate(args)
  end

end
