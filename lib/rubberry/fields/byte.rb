module Rubberry
  module Fields
    class Byte < Base
      class ValueProxy < Proxy
        def objectize(value)
          case value
          when ::String
            value.bytes.first
          when ::Numeric
            value.to_i
          else
            nil
          end
        end
      end
    end
  end
end
