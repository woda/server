require 'logger'
require 'colorize'
require 'set'
require 'thread'

# colorize doesn't implement this one for some reason...
String.class_eval do
  def bold
    if self =~ /^\e\[\d+;(\d+);(\d+)m(.*)\e\[0m$/
      "\e[1;#{$1};#{$2}m#{$3}\e[0m"
    else
      "\e[1;39;49m#{self}\e[0m"
    end
  end
end

# TODO: Set the various log types through the command line arguments

# There is a general norm: before the definition of a function utilizing a custom log type,
# call LOG.{show,hide}_name_of_type, so that the type is registered (call use show or hide
# according to whether it should be shown or hidden by default)
class Log < Logger
  attr_reader :types

  def initialize
    super STDOUT
    @types = Set.new

    old_formatter = self.formatter
    self.formatter = Proc.new { |severity, time, progname, msg|
#      return old_formatter.call severity, time, progname, msg unless severity == Logger::INFO
      msg_str = msg.class == Proc ? msg.call.to_s : msg.to_s
      time_str = time.strftime "%x %X"
#      type_str = Thread.current[:current_type]
      if @logdev.dev.tty?
#        type_str = type_str.blue.bold
        time_str = time_str.light_yellow
        severity = severity.to_s.magenta
      end
#      "#{severity} [#{time_str}] #{type_str}: #{msg_str}\n"
      "#{severity} [#{time_str}]: #{msg_str}\n"
    }
  end

  def log_type level, type, *args, &msg
    return unless @types.include? type.to_s
    Thread.current[:current_type] = type
    args.each { |m| self.send level, m }
    self.send(level, &msg) if msg
  end

  OUTPUT_TYPES = ['fatal', 'error', 'warn', 'info', 'debug']
  SEVERITY_REGEX = Regexp.new("^(#{OUTPUT_TYPES.join "|"})_(.*)$")

  def method_missing method, *args, &block
    if method.to_s =~ SEVERITY_REGEX
      log_type $1, $2, *args, &block
    elsif method.to_s =~ /^show_(.*)$/
      @types << $1
    elsif method.to_s =~ /^hide_(.*)$/
      @types.delete $1
    else
      super
    end
  end
end

LOG = Log.new
LOG.level = Logger::DEBUG if $DEBUG
