require 'spec_helper'

describe Rubberry::Base do
  subject{ SomeNamespace::DefaultModel }

  describe '.index_name' do
    specify{ expect(SomeNamespace::DefaultModel.index_name).to eq('test_some_namespaces') }
    specify{ expect(SomeNamespace::SomeModel.index_name).to eq('test_some_index') }
  end

  describe '.type_name' do
    specify{ expect(SomeNamespace::DefaultModel.type_name).to eq('default_model') }
    specify{ expect(SomeNamespace::SomeModel.type_name).to eq('some_type') }
  end

  describe '.document_ttl' do
    specify{ expect(SomeNamespace::DefaultModel.document_ttl).to be_nil }
    specify{ expect(SomeNamespace::SomeModel.document_ttl).to eq('10w') }
  end

  describe '.document_ttl?' do
    specify{ expect(SomeNamespace::DefaultModel.document_ttl?).to be_falsy }
    specify{ expect(SomeNamespace::SomeModel.document_ttl?).to be_truthy }
  end

  describe '.abstract?' do
    specify{ expect(Abstract.abstract?).to be_truthy }
    specify{ expect(User.abstract?).to be_falsy }
  end

  describe '.context' do
    specify{ expect(User.context).to be_instance_of(Rubberry::Context) }
    specify{ expect(User.context.equal?(User.context)).to be_falsy }
    specify{ expect(User.context.send(:request)).to eq(
      body: { version: true }, index: 'test_users', type: ['user']
    ) }
  end

  describe '.connection' do
    specify{ expect(subject.connection).to be_instance_of(Elasticsearch::Transport::Client) }
  end

  describe '.config' do
    specify{ expect(subject.config).to be_instance_of(Rubberry::Configuration) }
  end

  describe '#connection' do
    subject{ User.new }
    specify{ expect(subject.connection).to be_instance_of(Elasticsearch::Transport::Client) }
  end

  describe '#config' do
    subject{ User.new }
    specify{ expect(subject.config).to be_instance_of(Rubberry::Configuration) }
  end
end
