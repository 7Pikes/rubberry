require 'spec_helper'

describe Rubberry::Base do
  subject{ stub_model('User::CustomEvent') }

  describe '.index_name' do
    specify{ expect(subject.index_name).to eq('test_user_custom_events') }

    context do
      before{ subject.index_name('events') }
      specify{ expect(subject.index_name).to eq('test_events') }
    end
  end

  describe '.type_name' do
    specify{ expect(subject.type_name).to eq('user_custom_event') }

    context do
      before{ subject.type_name('event') }
      specify{ expect(subject.type_name).to eq('event') }
    end
  end

  describe '.document_ttl' do
    specify{ expect(subject.document_ttl).to be_nil }

    context do
      before{ subject.document_ttl('8w') }
      specify{ expect(subject.document_ttl).to eq('8w') }
    end
  end

  describe '.context' do
    subject{ stub_model('Event') }
    specify{ expect(subject.context).to be_instance_of(Rubberry::Context) }
    specify{ expect(subject.context.equal?(subject.context)).to be_falsy }
    specify{ expect(subject.context.send(:request)).to eq(
      body: { version: true }, index: 'test_events', type: ['event']
    ) }
  end

  describe '.connection' do
    specify{ expect(subject.connection).to be_instance_of(Elasticsearch::Transport::Client) }
  end

  describe '.config' do
    specify{ expect(subject.config).to be_instance_of(Rubberry::Configuration) }
  end

  describe '#connection' do
    subject{ stub_model('Event').new }
    specify{ expect(subject.connection).to be_instance_of(Elasticsearch::Transport::Client) }
  end

  describe '#config' do
    subject{ stub_model('Event').new }
    specify{ expect(subject.config).to be_instance_of(Rubberry::Configuration) }
  end
end
