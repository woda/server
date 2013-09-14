require 'fileutils'

module Storage
  def self.use_aws= use
    @use_aws = use
  end

  def self.path= p
    @path = p
    puts @path
  end

  class FakeObject
    def initialize path, bucket
      @base = "#{path}/#{bucket}"
      puts @base
      FileUtils.mkpath @base
    end

    def create path, info = {}
      real_path = Pathname.new("#{@base}/#{path}")
      FileUtils.mkpath real_path.dirname
      File.open real_path, "w" do |f|
        f.write info[:data]
      end
    end

    class SimulatedFile
      def initialize path
        @path2 = path
      end

      def read opt = {}
        f = File.new @path2
        res = f.read
        f.close
        res
      end
    end

    def [] file
      SimulatedFile.new "#{@base}/#{file}"
    end
  end

  def self.[] bucket
    puts @path
    @s3 = AWS::S3.new if @use_aws && !@s3
    if @use_aws
      @s3.buckets[bucket].objects
    else
      puts "a : #{@path}/#{bucket}"
      FakeObject.new @path, bucket
    end
  end

  def self.clear bucket
    @s3 = AWS::S3.new if @use_aws && !@s3
    if @use_aws
      s3 = AWS::S3.new
      bucket = s3.buckets[bucket]
      bucket.clear!
    else
      rm_r "#{@path}/#{bucket}"
    end
  end
end
