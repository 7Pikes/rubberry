module Rubberry
  module Fields
    class Boolean < Base
      class ValueProxy < Proxy
        def objectize(value)
          !!value
        end
      end
    end
  end
end
