# Protocol tester by Woda Group
# (C) 2012-2013
# Kevin Guillouard && Etienne Linck

require "highline/import"
require 'socket'      # Sockets are in standard library
require 'openssl'
require './user'
require './connection'
require './json_controller'

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

def sendFile(fileName, s)
  return "File does not exist" if !File.exists?(fileName)
  puts("Sending \"#{fileName}\"...")
  file = File.open fileName, 'rb'
  fileContent = file.read
  s.send fileContent, 0
  "Sent successfully"
end

user = User.instance

help 
loop {
  input = ask "$ [#{User.instance.logged_as}] > "
  exit if input == "exit" || input == "quit"
  help if input == "help" || input == "--help"
  inputA = input.to_s.split
  if inputA[0] == "send"
    inputA.delete_at(0)
    fileName = inputA.join ' '
    puts sendFile fileName, connection
  end
 
  if inputA[1] == "user" || inputA[1] == "as"
    puts " "
    if User.respond_to? inputA[0]
      User.send(inputA[0], inputA, connection)
      puts " "
    else
      puts "** " + "User.".green + inputA[0].yellow + ": Unknown command"
      puts " "
    end
  end
}
