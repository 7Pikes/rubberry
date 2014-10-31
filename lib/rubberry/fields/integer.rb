module Rubberry
  module Fields
    class Integer < Base
      class ValueProxy < Proxy
        def objectize(value)
          value.to_i
        end
      end
    end
  end
end
