require 'set'

module Controller
  class Base
    attr_reader :connection
    attr_accessor :param

    def initialize connection
      @connection = connection
      @param = {}
    end

    def self.get_actions
      @actions
    end

    def self.get_before
      @before
    end

    def actions
      self.class.get_actions
    end

    def before
      self.class.get_before
    end

    def self.actions *args
      @actions ||= Set.new []
      @actions |= Set.new args.map { |a| a.to_s }
    end

    def self.before fct, *args
      @before ||= {}
      (args || []).each do |a|
        @before[a] ||= []
        @before[a] << fct
      end
    end

    def route
      raise InvalidArgument.new("#{self.class.name} needs a custom route") unless (self.class.name =~ /(.*)Controller/)
      $1.underscore
    end

    def check_authenticate
      if connection.data[:current_user].nil?
        connection.error_need_login
        return false
      end
      true
    end

    def check_create_params
      check_params(*(model.properties.find_all { |p| model.updatable?(p.name) && p.required? }.map(&:name)))
    end

    def check_update_params
      check_any_params(*(model.properties.find_all { |p| model.updatable?(p.name) }.map(&:name)))
    end

    def has_param? p
      param.has_key? p.to_s
    end
    
    def check_params *params
      @connection.error_missing_params unless params.all? { |p| has_param? p }
    end

    def check_any_params *params
      @connection.error_missing_params unless params.any? { |p| has_param? p }
    end

    def set_properties inst
      model.properties.find_all { |p| model.updatable?(p.name) }.each do |p|
        inst.send("#{p.name}=".to_sym, param[p.name.to_s]) if param.has_key?(p.name.to_s)
      end
      inst
    end

    # Returns the model for the controller. Override to use check_create_params or check_update_params
    def model
      nil
    end

    def destroy
    end
  end
end
