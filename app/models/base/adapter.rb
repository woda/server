require 'do_postgres'
require 'dm-do-adapter'

module DataMapper
  module Adapters

    class PostgresAdapter < DataObjectsAdapter

      module SQL #:nodoc:
        private

        # @api private
        def supports_returning?
          true
        end

        def like_operator(operand)
          'ILIKE'
        end
      end

      include SQL

    end

    const_added(:PostgresAdapter)

  end
end
