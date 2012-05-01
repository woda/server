require 'set'

module Controller
  class Base
    attr_reader :connection
    attr_accessor :param

    def initialize connection
      @connection = connection
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
        error_need_login
        return false
      end
      true
    end
  end
end
