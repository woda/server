require 'set'

module Controller
  class Base
    attr_reader :connection
    attr_accessor :param

    def initialize connection
      @connection = connection
      @param = {}
    end

    ##
    # Returns all the actions a controller can perform
    #
    # Returns an array of symbols
    def self.get_actions
      @actions
    end

    ##
    # Returns a hash of the functions to perform before each action.
    #
    # Returns a hash of symbols to array of symbols.
    def self.get_before
      @before
    end

    ##
    # Same as self.get_actions
    def actions
      self.class.get_actions
    end

    ##
    # Same as self.get_before
    def before
      self.class.get_before
    end

    ##
    # Adds actions to the set of actions a controller can perform
    #
    # Takes a list of symbols
    def self.actions *args
      @actions ||= Set.new []
      @actions |= Set.new args.map { |a| a.to_s }
    end

    ##
    # Adds functions to perform before an action.
    #
    # fct is the symbol of the action
    # *args are the symbols of all the functions to perform before executing
    #   the action. They will be performed in order.
    def self.before fct, *args
      @before ||= {}
      (args || []).each do |a|
        @before[a] ||= []
        @before[a] << fct
      end
    end

    ##
    # Returns the name of the controller type (aka, route).
    def route
      raise InvalidArgument.new("#{self.class.name} needs a custom route") unless (self.class.name =~ /(.*)Controller/)
      $1.underscore
    end

    ##
    # The most common 'before' function: checks that the user is authenticated
    # before calling the action.
    def check_authenticate
      if connection.data[:current_user].nil?
        connection.error_need_login
        return false
      end
      true
    end

    ##
    # A before action for create CRUD functions: checks that all the necessary
    # members of the model are indeed in the parameters
    def check_create_params
      check_params(*(model.properties.find_all { |p| model.updatable?(p.name) && p.required? }.map(&:name)))
    end

    ##
    # A before action for update CRUD functions: checks that any updatable
    # member of the model is indeed in the parameters
    def check_update_params *args
      check_any_params(*(model.properties.find_all { |p| model.updatable?(p.name) }.map(&:name) + args))
    end

    ##
    # Checks is p (which can be a string or a symbol) is in the request.
    def has_param? p
      param.has_key? p.to_s
    end

    ##
    # Checks whether a set of params is in the request
    def check_params *params
      @connection.error_missing_params unless params.all? { |p| has_param? p }
    end

    ##
    # Checks whether any param of a set of params is in the request
    def check_any_params *params
      @connection.error_missing_params unless params.any? { |p| has_param? p }
    end

    ##
    # Automatically sets the properties of an instance (inst) of the model
    # according to the params.
    def set_properties inst
      model.properties.find_all { |p| model.updatable?(p.name) }.each do |p|
        inst.send("#{p.name}=".to_sym, param[p.name.to_s]) if param.has_key?(p.name.to_s)
      end
      inst
    end

    ##
    # Returns the model for the controller. Override to use check_create_params or check_update_params
    def model
      nil
    end

    ##
    # Called when the controller is removed or when the connection is closed
    def destroy
    end
  end
end
