module SomeNamespace
  class DefaultModel < Rubberry::Base
    mappings do
    end
  end

  class SomeModel < Rubberry::Base
    index_name :some_index
    type_name :some_type
    document_ttl '10w'

    mappings do
    end
  end
end

class Abstract < Rubberry::Base
  abstract!
  mappings do
  end
end

module Events
  class Base < Rubberry::Base
    abstract!

    mappings do
      field :name
    end
  end

  class Error < Base
    mappings do
      field :message
      field :backtrace, array: true
    end
  end

  class Info < Base
    index_name 'user_events'

    mappings do
      field :message
    end
  end
end

class UserEvent < Rubberry::Base
  mappings do
    field :name
  end
end

class User < Rubberry::Base
  mappings do
    field :name
    field :counter, type: 'integer', default: 0
    field :counter1, type: 'integer', default: 0
    field :counter2, type: 'integer'
  end
end

class UserWithTTL < Rubberry::Base
  index_name :users
  document_ttl '2s'

  mappings do
    field :name
  end
end

class UserWithTimestamp < Rubberry::Base
  index_name :users

  mappings do
    _timestamp enabled: true, store: true
    field :name
  end
end

class Model < Rubberry::Base
  mappings do
    field :string
    field :string_with_default, default: 'default string'
    field :integer, type: 'integer'
    field :multi_field, type: 'string' do
      field :raw, type: 'string', index: false
    end
    field :object do
      field :subfield, type: 'string'
    end
  end
end

class SubModel < Model
end

class EmptyModels < Rubberry::Base
end

class Admin < Rubberry::Base
  mappings do
    field :name
    field :counter, type: 'integer', default: 0
  end
  validates :name, presence: true
end

class SomeUser < Rubberry::Base
  type_name :user

  mappings do
    field :name
    field :handsome, type: 'boolean', default: true
    field :counter, type: 'integer', default: 0
  end
end
