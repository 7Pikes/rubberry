module Rubberry
  module Fields
    class Double < Base
      class ValueProxy < Proxy
        def objectize(value)
          value.to_f if value.respond_to?(:to_f)
        end
      end
    end
  end
end

