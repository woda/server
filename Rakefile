require 'active_support'
require 'yaml'
require 'fileutils'

desc "migrates database destructively"
task :migrate do
  require_relative 'lib/environment'
  DataMapper.auto_migrate!
end

desc "migrates database non destructively"
task :upgrade do
  require_relative 'lib/environment'
  DataMapper.auto_upgrade!
end

SRC = File.expand_path('..', __FILE__)

desc "copy in flog_temp with 1.8 hash syntax, ascii characters and unix 
end_of_line"
task :convert do
  flog_temp = File.join(SRC, 'flog_temp/lib')
  FileUtils.mkdir_p(flog_temp) rescue nil
  Dir.chdir(flog_temp)
  Dir.glob('**/*.rb') { |name| File.delete(name) }
  Dir.chdir(SRC)
  list = Dir.glob('**/*.rb')
  list << "server"
  list.each do |name|
    arr = IO.readlines(File.join(SRC, name))
    path = File.join(flog_temp, name)
    puts path
    FileUtils.mkdir_p(File.expand_path('..', path)) rescue nil
    File.open(path, "w") do |f|
      arr.each do |line|
        line.gsub!(/:(nodoc|startdoc|stopdoc):/, "")
        line.gsub!(/(\w+):\s+/, ':\1 => ')
	line.gsub!(/\.\(/, ".call(")
        f.print line
      end
    end
  end
end
