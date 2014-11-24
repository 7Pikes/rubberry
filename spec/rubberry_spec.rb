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
    specify{ expect(Rubberry.indices.map(&:class)).to eq([Rubberry::Index, Rubberry::Index]) }
    specify{ expect(Rubberry.indices.map(&:index_name)).to eq(['test_events', 'test_user_events']) }
  end

  describe '.index_models', classes: true do
    specify{ expect(Rubberry.index_models).to eq(
      'test_user_events' => [Events::Info, UserEvent],
      'test_events' => [Events::Error]
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
