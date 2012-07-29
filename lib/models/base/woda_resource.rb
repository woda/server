require 'set'
require 'data_mapper'

module WodaResource
  def self.included klass
    klass.extend ClassMethods
  end

  private
  module ClassMethods
    def updatable? property
      @updatable && @updatable.include?(property)
    end

    def updatable_properties
      @updatable ||= Set.new
    end

    def updatable_property name, *args
      property name, *args
      @updatable ||= Set.new
      @updatable << name
    end
  end
end
