require 'ostruct'

class OpenStruct
  unless method_defined?(:[])
    def [](name)
      @table[name.to_sym]
    end
  end

  unless method_defined?(:[]=)
    def []=(name, value)
      modifiable[new_ostruct_member(name)] = value
    end
  end
end
