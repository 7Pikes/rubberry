require 'spec_helper'

describe Rubberry do
  before classes: true do
    stub_model('Events::Base') do
      abstract!

      mappings do
        field :name
      end
    end

    stub_class('Events::Error', Events::Base) do
      mappings do
        field :message
        field :backtrace, array: true
      end
    end

    stub_class('Events::Info', Events::Base) do
      index_name 'user_events'

      mappings do
        field :message
      end
    end

    stub_model('UserEvent') do
      mappings do
        field :message
      end
    end
  end

  describe '.configure' do
    specify{ expect{|b| Rubberry.configure(&b) }.to yield_with_args(Rubberry.config) }
  end

  describe '.config' do
    specify{ expect(subject.config).to be_instance_of(Rubberry::Configuration) }
    specify{ expect(subject.config).to eq(subject.config) }
  end

  describe '.indices', classes: true do
    specify{ expect(Rubberry.indices.map(&:class)).to eq([
      Rubberry::Index, Rubberry::Index, Rubberry::Index, Rubberry::Index, Rubberry::Index, Rubberry::Index,
      Rubberry::Index, Rubberry::Index, Rubberry::Index, Rubberry::Index
    ]) }

    specify{ expect(Rubberry.indices.map(&:index_name)).to eq([
      'test_some_namespaces', 'test_some_index', 'test_events', 'test_user_events', 'test_users', 'test_models',
      'test_sub_models', 'test_empty_models', 'test_admins', 'test_some_users'
    ]) }
  end

  describe '.index_models', classes: true do
    specify{ expect(Rubberry.index_models).to eq(
      'test_some_namespaces' => [SomeNamespace::DefaultModel],
      'test_some_index' => [SomeNamespace::SomeModel],
      'test_events' => [Events::Error],
      'test_user_events' => [Events::Info, UserEvent],
      'test_users' => [User, UserWithTTL, UserWithTimestamp],
      'test_models' => [Model],
      'test_sub_models' => [SubModel],
      'test_empty_models' => [EmptyModels],
      'test_admins' => [Admin],
      'test_some_users' => [SomeUser]
    ) }
  end

  describe '.mappings_for', classes: true do
    specify{ expect(Rubberry.mappings_for('test_user_events')).to eq(
      'user_event' => {
        properties: { 'message' => { type: 'string' } }
      },
      'info' => {
        properties: { 'name' => { type: 'string' }, 'message' => { type: 'string' } }
      }
    ) }
  end

  describe '.wait_for_status' do
  end
end
