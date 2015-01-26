module Rubberry
  module Fields
    class Object < Base
      class ValueProxy < Proxy
        def objectize(value)
          value = (value || {}).with_indifferent_access

          if __field__.children.empty? && __field__.allow_any?
            super(value)
          else
            __field__.children.each_with_object(::OpenStruct.new) do |field, result|
              result[field.name] = field.type_cast(value[field.name])
            end
          end
        end

        def elasticize
          return nil if __target__.nil?

          if __field__.children.empty? && __field__.allow_any?
            super
          else
            __field__.children.each_with_object({}) do |field, result|
              result[field.name] = __target__[field.name].elasticize
            end
          end
        end
      end
    end
  end
end
