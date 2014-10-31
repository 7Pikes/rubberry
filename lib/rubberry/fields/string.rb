module Rubberry
  module Fields
    class String < Base
      class ValueProxy < Proxy
        def objectize(value)
          value.to_s
        end
      end
    end
  end
end
