# Protocol tester by Woda Group
# (C) 2012-2013
# Kevin Guillouard && Etienne Linck

require "highline/import"
require 'socket'      # Sockets are in standard library
require 'openssl'

if !ARGV.any?
    puts 'Usage: ruby client.rb host port'
    exit
end

host=ARGV[0]
port=ARGV[1]

socket = TCPSocket.new(host, port)
sslContext = OpenSSL::SSL::SSLContext.new
serverSocket = OpenSSL::SSL::SSLSocket.new(socket, sslContext)
serverSocket.sync_close = true
serverSocket.connect

serverSocket.puts("json");

line = serverSocket.gets

if (line != "{\"status\":\"ok\",\"type\":\"connection_ok\",\"message\":\"Connected successfully\"}\n")
  puts "[CONNECTION ERROR]: Server response was negative for connection"
  puts "\t\t\tPlease try again later"
  exit
end

puts "Connected to host #{host} on port #{port}"
puts "Type help to get the help"

def help()
  puts ""
  puts "Protocol tester by Woda Group"
  puts "(C)2012-2013"
  puts "send {filename}: Send the file {filename} to the connected host"
  puts "exit || quit: Close the program"
  puts "create user {login} {password} {firstname} {lastname} {email}: To create a new user on the Database"
  puts "update user {login} {password} {firstname} {lastname} {email}: To update a existing user's password"
  puts "delete user {login}: To delete an user from the Database"
  puts "show user {login}: Show the user login and his details"
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

def createUser(command, s)
  login = command[2]
  password = command[3]
  firstname = command[4]
  lastname = command[5]
  email = command[6]

  s.puts("{\"action\":\"users/create\",\"login\":\"#{login}\",\"password\":\"#{password}\",\"first_name\":\"#{firstname}\",\"last_name\":\"#{lastname}\",\"email\":\"#{email}\"}")

  res = s.gets
  if (res != "{\"status\":\"ok\",\"type\":\"signup_successful\",\"message\":\"Successfully created user\"}\n")
    puts "Unable to create user #{login} with password #{password}"
    puts "** Server response: #{res}"
  else
    puts "User created successfully"
  end
end

def updateUser(command, s)
  login = command[2]
  password = command[3]
  firstname = command[4]
  lastname = command[5]
  email = command[6]
  
  s.puts("{\"action\":\"users/update\",\"login\":\"#{login}\",\"password\":\"#{password}\",\"first_name\":\"#{firstname}\",\"last_name\":\"#{lastname}\",\"email\":\"#{email}\"}")

  res = s.gets
  if (res != "{\"status\":\"ok\",\"type\":\"update_successful\",\"message\":\"Successfully updated user\"}\n")
    puts "Unable to update user #{login} with password #{password}"
    puts "** Server response: #{res}"
  else
    puts "User updated successfully"
  end
end

def deleteUser(login, s)

  s.puts("{\"action\":\"users/delete\",\"login\":\"#{login}\"}")
  
  res = s.gets
  if (res != "{\"status\":\"ok\",\"type\":\"delete_successful\",\"message\":\"Successfully deleted user\"}\n")
    puts "Unable to delete user #{login}"
    puts "** Server response: #{res}"
  else
    puts "User deleted successfully"
  end
end

def showUser(login, s)
  s.puts("{\"action\":\"users/show\",\"login\":\"#{login}\"}")
  res = s.gets

## TODO: here paste the code. 
end

help 
loop {
  input = ask '$> '
  exit if input == "exit" || input == "quit"
  help if input == "help" || input == "--help"
  
  inputA = input.to_s.split
  if inputA[0] == "send"
    inputA.delete_at(0)
    fileName = inputA.join ' '
    puts sendFile fileName, serverSocket
  end
  
  if inputA[1] == "user"
    createUser inputA, serverSocket if inputA[0] == "create"
    updateUser inputA, serverSocket if inputA[0] == "update"
    deleteUser inputA[2], serverSocket if inputA[0] == "delete"
    showUser inputA[2], serverSocket if inputA[0] == "show"
  end
}
