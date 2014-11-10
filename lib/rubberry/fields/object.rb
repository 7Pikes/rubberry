module Rubberry
  module Fields
    class Object < Base
      class ValueProxy < Proxy
        def objectize(value)
          value = (value || {}).with_indifferent_access
          __field__.children.each_with_object(::OpenStruct.new) do |field, result|
            result[field.name] = field.type_cast(value[field.name])
          end
        end

        def elasticize
          return nil if __target__.nil?
          __field__.children.each_with_object({}) do |field, result|
            result[field.name] = __target__[field.name].elasticize
          end
        end
      end
    end
  end
end
