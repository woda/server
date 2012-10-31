# Protocol tester by Woda Group
# (C) 2012-2013
# Kevin Guillouard && Etienne Linck

require "highline/import"
require 'socket'      # Sockets are in standard library
require 'openssl'
require './helpers/connection'
require './controllers/json_controller'
require './controllers/user_controller'
require './controllers/sync_controller'

if !ARGV.any?
    puts 'Usage: ruby client.rb host port'
    exit
end

host=ARGV[0]
port=ARGV[1]

connection = Connection.new(host, port)

puts "Connected to host #{host} on port #{port}"
puts "Type help to get the help"

def help
  puts ""
  puts "Protocol tester by Woda Group"
  puts "(C)2012-2013"
  puts "exit".yellow + " || " + "quit".yellow + ": Close the program"
  puts "help ".yellow + "{user || file}: Get any help concerning the parameter"
  puts ""
end

def user_action(inputA, connection)
  if inputA[1] == "user" || inputA[1] == "as"
    puts " "
    if UserController.respond_to? inputA[0]
      UserController.send(inputA[0], inputA, connection)
      puts " "
    else
      puts "** " + "UserController.".green + inputA[0].yellow + ": Unknown command"
      puts " "
    end
  end  
end

def file_action(inputA, connection)
  if inputA[1] == "file"
    puts " "
    if SyncController.respond_to? inputA[0]
      sync = Sync.open inputA[2]
      sctrl = SyncController.new sync, connection if sync.nil? == false
      SyncController.send(inputA[0], inputA, connection)
      puts " "
    else
      puts "** " + "UserController.".green + inputA[0].yellow + ": Unknown command"
      puts " "
    end
  end  
  if inputA[1] == "file"
    puts ""
    if SyncController.respond_to? inputA[0]
      sync = Sync.open inputA[2]
      scontroller = nil
      if sync.nil? == false
        scontroller = SyncController.new sync, connection
        scontoller.call(inputA[0], inputA)
      end
      puts ""
    else
      puts "** " + "SyncController.".green + inputA[0].yellow + ": Unknown command"
      puts ""
    end
  end
end

user = User.instance

help 
loop {
  input = ask "$ [#{user.logged_as}] > "
  exit if input == "exit" || input == "quit"
  help if input == "help" || input == "--help"
  inputA = input.to_s.split
  
  user_action inputA, connection
  file_action inputA, connection
}