require 'set'
require 'data_mapper'

##
# A woda resource. Defines convinience methods
module WodaResource
  def self.included klass
    klass.extend ClassMethods
  end

  private
  module ClassMethods
    before :save, :set_id

    def set_id
      return if id
      id = self.class.max(:id) + 1
    end

    ##
    # Is the property updatable?
    def updatable? property
      @updatable && @updatable.include?(property)
    end

    ##
    # The list of all updatable properties
    def updatable_properties
      @updatable ||= Set.new
    end

    ##
    # Add a new updatable property
    def updatable_property name, *args
      property name, *args
      @updatable ||= Set.new
      @updatable << name
    end
  end
end
