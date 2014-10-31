module Rubberry
  module Fields
    class Binary < Base
      class ValueProxy < Proxy
        def objectize(value)
          case value
          when ::String
            ::StringIO.new(::Base64.decode64(value))
          when ::IO, ::StringIO
            value
          else
            nil
          end
        end

        def elasticize
          return nil if _target.nil?
          ::Base64.encode64(_target.read)
        end
      end
    end
  end
end
