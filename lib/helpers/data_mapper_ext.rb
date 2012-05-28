require 'data_mapper'

module DataMapper
  class SaveFailureError
    def to_s
      "#{super}: #{resource.errors.to_a.flatten.join ' & '}"
    end
  end
end
