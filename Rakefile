require 'active_column'
require 'fileutils'

SRC = File.expand_path('..', __FILE__)

desc "copy in flog_temp with 1.8 hash syntax, ascii characters and unix 
end_of_line"
task :convert do
  flog_temp = File.join(SRC, 'flog_temp')
  Dir.mkdir(flog_temp) rescue nil
  Dir.chdir(flog_temp)
  Dir.glob('**/*.rb') { |name| File.delete(name) }
  Dir.chdir(SRC)
  list = Dir.glob('lib/**/*.rb')
  list.each do |name|
    arr = IO.readlines(File.join(SRC, name))
    FileUtils.mkdir_p(File.expand_path('..', File.join(flog_temp, name))) rescue nil
    File.open(File.join(flog_temp, name), "wb:utf-8") do |f|
      arr.each do |line|
        line.gsub!(/:(nodoc|startdoc|stopdoc):/, "")
        line.gsub!(/(\w+):\s+/, ':\1 => ')
        f.print line
      end
    end
  end
end

require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end

desc "Generate code coverage"
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end
