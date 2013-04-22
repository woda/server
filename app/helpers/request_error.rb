##
# The exception class for when the request is invalid.
# sym is an error symbol and str is an error message
class RequestError < Exception
	attr_reader :sym, :str

	def initialize sym, str
		@sym = sym
		@str = str
	end
end
