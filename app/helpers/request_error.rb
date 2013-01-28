class RequestError < Exception
	attr_reader :sym, :str

	def initialize sym, str
		@sym = sym
		@str = str
	end
end
