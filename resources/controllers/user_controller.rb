require File.join(File.dirname(__FILE__), "..", "models/user")
require "./helpers/connection"

class UserController

  def self.create(command, connection)
    login = command[2]
    password = command[3]
    firstname = command[4]
    lastname = command[5]
    email = command[6]
    
    json_data = JsonController.generate("action"=>"users/create",
                                        "login"=>login,
                                        "password"=>password,
                                        "first_name"=>firstname,
                                        "last_name"=>lastname,
                                        "email"=>email)
    connection.put_data json_data[1.. json_data.size - 2]
    
    res = connection.get_data
    res = JsonController.new(res)
    if res.error?
      puts "Unable to create user #{login} with password #{password}".red
      puts "** Server response: " + res.get("message").yellow
    else
      puts "User ".green + login.yellow + " created successfully".green
    end
  end
  
  def self.login(command, connection)
    login = command[2]
    password = command[3]
    
    json_data = JsonController.generate("action"=>"users/login",
                                        "login"=>login,
                                        "password"=>password)
    
    connection.put_data json_data[1..json_data.size - 2]
    
    res = connection.get_data
    res = JsonController.new(res)
    if res.error?
      puts "Unable to login as #{login}".red
      puts "**Server response: " + res.get("message").yellow
    else
      User.instance.set_logged_as login.blue
      puts res.get("message").green + " as ".green + login.blue
    end
  end
  
  def self.logout(command, connection)
    login = command[2]
    json_data = JsonController.generate("action"=>"users/logout",
                                        "login"=>login)
    connection.put_data json_data[1..json_data.size - 2]
    
    res = connection.get_data
    res = JsonController.new(res)
    if (res.error?)
      puts "Unable to logout #{login}".red
      puts "** Server response: " + res.get("message").yellow
    else
      puts "User logout successfully".green
      User.instance.set_logged_as "Anonymous".blue
    end
  end
  
  def self.update(command, connection)
    login = command[2]
    password = command[3]
    firstname = command[4]
    lastname = command[5]
    email = command[6]
    
    json_data = JsonController.generate("action"=>"users/update",
                                        "login"=>login,
                                        "password"=>password,
                                        "first_name"=>firstname,
                                        "last_name"=>lastname,
                                        "email"=>email)
    
    connection.put_data json_data[1..json_data.size - 2]
    
    res = connection.get_data
    res = JsonController.new(res)
    if (res.error?)
      puts "Unable to update user #{login}".red
      puts "** Server response: " + res.get("message").yellow
    else
      puts "User ".green + login.yellow + " updated successfully".green
    end
  end
  
  def self.delete(command, connection)
    
    json_data = JsonController.generate("action"=>"users/delete",
                                        "login"=>command[2])
    res = connection.get_data
    res = JsonController.new(res)
    if (res.error?)
      puts "Unable to delete user #{login}".red
      puts "** Server response: " + res.get("message").yellow
    else
      puts "User deleted successfully"
    end
  end
  
  def self.help(command, connection)
    puts "login".yellow + " as " + "login".underline + " " + "password".underline + ": Logged as user <login>"
    puts "logout".yellow + " user: To loggout from your session"
    puts "create".yellow + " user " + 
      "login".underline + " " + "password".underline + " " +
      "first_name".underline + " " + "last_name".underline + " " + 
      "email".underline + ": To create the user <login>"
    puts "upade".yellow + " user " + 
      "login".underline + " " + "password".underline + " " +
      "first_name".underline + " " + "last_name".underline + " " + 
      "email".underline + ": To update an user"
    puts "delete".yellow + " user " + "login".underline + ": To delete the user <login>"
    puts "show".yellow + " user " + "login".underline + ": To show the user <login>"
  end  
  
  def self.show(command, connection)
    json_data = JsonController.generate("action"=>"users/show",
                                        "login"=>command[1])
    connection.put_data json_data[1..json_data.size - 2]
    
    res = connection.get_data
    res = JsonController.new(res)
    if (res.error?)
      puts "Unable to show user #{User.instance.logged_as}".red
      puts "** Server response: " + res.get("message").yellow
    else
      res = res.nested.to_s
      res = res.gsub(/=>/, ":")
       res = JsonController.new(res)
       res = res.parsed_string
       res.each do |key, value|
        puts "#{key}: #{value}"
       end
     end
   end

end
