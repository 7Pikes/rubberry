require 'spec_helper'

describe Rubberry::Configuration do
  subject{ Rubberry::Configuration.new }

  describe '#initialize' do
    specify{ expect(subject.index).to be_instance_of(OpenStruct) }
    specify{ expect(subject.client).to be_instance_of(OpenStruct) }
    specify{ expect(subject.query_mode).to eq(:must) }
    specify{ expect(subject.filter_mode).to eq(:and) }
    specify{ expect(subject.post_filter_mode).to be_nil }
    specify{ expect(subject.wait_for_status).to be_nil }
    specify{ expect(subject.wait_for_status_timeout).to eq('30s') }
    specify{ expect(subject.refresh).to be_falsy }
    specify{ expect(subject.connection_per_thread).to be_truthy }
    specify{ expect(subject.dynamic_scripting).to be_falsy }
    specify{ expect(subject.index_namespace).to eq('test') }
    specify{ expect(subject.almost_expire_threshold).to eq(5000) }
  end

  describe '#query_mode' do
    specify{ expect{ subject.query_mode = nil }.to raise_error(Optionable::Invalid) }
    specify{ expect{ subject.query_mode = :invalid_value }.to raise_error(Optionable::Invalid) }

    context do
      before{ subject.query_mode = :must }
      specify{ expect(subject.query_mode).to eq(:must) }
      specify{ expect(subject.query_mode?).to be_truthy }
    end

    context do
      before{ subject.query_mode = 'must' }
      specify{ expect(subject.query_mode).to eq('must') }
      specify{ expect(subject.query_mode?).to be_truthy }
    end

    context do
      before{ subject.query_mode = :should }
      specify{ expect(subject.query_mode).to eq(:should) }
      specify{ expect(subject.query_mode?).to be_truthy }
    end

    context do
      before{ subject.query_mode = 'should' }
      specify{ expect(subject.query_mode).to eq('should') }
      specify{ expect(subject.query_mode?).to be_truthy }
    end

    context do
      before{ subject.query_mode = :dis_max }
      specify{ expect(subject.query_mode).to eq(:dis_max) }
      specify{ expect(subject.query_mode?).to be_truthy }
    end

    context do
      before{ subject.query_mode = 'dis_max' }
      specify{ expect(subject.query_mode).to eq('dis_max') }
      specify{ expect(subject.query_mode?).to be_truthy }
    end

    context do
      before{ subject.query_mode = 0.5 }
      specify{ expect(subject.query_mode).to eq(0.5) }
      specify{ expect(subject.query_mode?).to be_truthy }
    end
  end

  describe '#filter_mode' do
    specify{ expect{ subject.filter_mode = nil }.to raise_error(Optionable::Invalid) }
    specify{ expect{ subject.filter_mode = :invalid_value }.to raise_error(Optionable::Invalid) }

    context do
      before{ subject.filter_mode = :or }
      specify{ expect(subject.filter_mode).to eq(:or) }
      specify{ expect(subject.filter_mode?).to be_truthy }
    end

    context do
      before{ subject.filter_mode = 'or' }
      specify{ expect(subject.filter_mode).to eq('or') }
      specify{ expect(subject.filter_mode?).to be_truthy }
    end

    context do
      before{ subject.filter_mode = :and }
      specify{ expect(subject.filter_mode).to eq(:and) }
      specify{ expect(subject.filter_mode?).to be_truthy }
    end

    context do
      before{ subject.filter_mode = 'and' }
      specify{ expect(subject.filter_mode).to eq('and') }
      specify{ expect(subject.filter_mode?).to be_truthy }
    end

    context do
      before{ subject.filter_mode = :must }
      specify{ expect(subject.filter_mode).to eq(:must) }
      specify{ expect(subject.filter_mode?).to be_truthy }
    end

    context do
      before{ subject.filter_mode = 'must' }
      specify{ expect(subject.filter_mode).to eq('must') }
      specify{ expect(subject.filter_mode?).to be_truthy }
    end

    context do
      before{ subject.filter_mode = :should }
      specify{ expect(subject.filter_mode).to eq(:should) }
      specify{ expect(subject.filter_mode?).to be_truthy }
    end

    context do
      before{ subject.filter_mode = 'should' }
      specify{ expect(subject.filter_mode).to eq('should') }
      specify{ expect(subject.filter_mode?).to be_truthy }
    end

    context do
      before{ subject.filter_mode = :dis_max }
      specify{ expect(subject.filter_mode).to eq(:dis_max) }
      specify{ expect(subject.filter_mode?).to be_truthy }
    end

    context do
      before{ subject.filter_mode = 'dis_max' }
      specify{ expect(subject.filter_mode).to eq('dis_max') }
      specify{ expect(subject.filter_mode?).to be_truthy }
    end

    context do
      before{ subject.filter_mode = 0.5 }
      specify{ expect(subject.filter_mode).to eq(0.5) }
      specify{ expect(subject.filter_mode?).to be_truthy }
    end
  end

  describe '#post_filter_mode' do
    specify{ expect{ subject.post_filter_mode = :invalid_value }.to raise_error(Optionable::Invalid) }

    context do
      before{ subject.post_filter_mode = nil }
      specify{ expect(subject.post_filter_mode).to be_nil }
      specify{ expect(subject.post_filter_mode?).to be_falsy }
    end

    context do
      before{ subject.post_filter_mode = :or }
      specify{ expect(subject.post_filter_mode).to eq(:or) }
      specify{ expect(subject.post_filter_mode?).to be_truthy }
    end

    context do
      before{ subject.post_filter_mode = 'or' }
      specify{ expect(subject.post_filter_mode).to eq('or') }
      specify{ expect(subject.post_filter_mode?).to be_truthy }
    end

    context do
      before{ subject.post_filter_mode = :and }
      specify{ expect(subject.post_filter_mode).to eq(:and) }
      specify{ expect(subject.post_filter_mode?).to be_truthy }
    end

    context do
      before{ subject.post_filter_mode = 'and' }
      specify{ expect(subject.post_filter_mode).to eq('and') }
      specify{ expect(subject.post_filter_mode?).to be_truthy }
    end

    context do
      before{ subject.post_filter_mode = :must }
      specify{ expect(subject.post_filter_mode).to eq(:must) }
      specify{ expect(subject.post_filter_mode?).to be_truthy }
    end

    context do
      before{ subject.post_filter_mode = 'must' }
      specify{ expect(subject.post_filter_mode).to eq('must') }
      specify{ expect(subject.post_filter_mode?).to be_truthy }
    end

    context do
      before{ subject.post_filter_mode = :should }
      specify{ expect(subject.post_filter_mode).to eq(:should) }
      specify{ expect(subject.post_filter_mode?).to be_truthy }
    end

    context do
      before{ subject.post_filter_mode = 'should' }
      specify{ expect(subject.post_filter_mode).to eq('should') }
      specify{ expect(subject.post_filter_mode?).to be_truthy }
    end

    context do
      before{ subject.post_filter_mode = :dis_max }
      specify{ expect(subject.post_filter_mode).to eq(:dis_max) }
      specify{ expect(subject.post_filter_mode?).to be_truthy }
    end

    context do
      before{ subject.post_filter_mode = 'dis_max' }
      specify{ expect(subject.post_filter_mode).to eq('dis_max') }
      specify{ expect(subject.post_filter_mode?).to be_truthy }
    end

    context do
      before{ subject.post_filter_mode = 0.5 }
      specify{ expect(subject.post_filter_mode).to eq(0.5) }
      specify{ expect(subject.post_filter_mode?).to be_truthy }
    end
  end

  describe '#wait_for_status' do
    specify{ expect{ subject.wait_for_status = :invalid_value }.to raise_error(Optionable::Invalid) }

    context do
      before{ subject.wait_for_status = nil }
      specify{ expect(subject.wait_for_status).to be_nil }
      specify{ expect(subject.wait_for_status?).to be_falsy }
    end

    context do
      before{ subject.wait_for_status = :green }
      specify{ expect(subject.wait_for_status).to eq(:green) }
      specify{ expect(subject.wait_for_status?).to be_truthy }
    end

    context do
      before{ subject.wait_for_status = 'green' }
      specify{ expect(subject.wait_for_status).to eq('green') }
      specify{ expect(subject.wait_for_status?).to be_truthy }
    end

    context do
      before{ subject.wait_for_status = :yellow }
      specify{ expect(subject.wait_for_status).to eq(:yellow) }
      specify{ expect(subject.wait_for_status?).to be_truthy }
    end

    context do
      before{ subject.wait_for_status = 'yellow' }
      specify{ expect(subject.wait_for_status).to eq('yellow') }
      specify{ expect(subject.wait_for_status?).to be_truthy }
    end

    context do
      before{ subject.wait_for_status = :red }
      specify{ expect(subject.wait_for_status).to eq(:red) }
      specify{ expect(subject.wait_for_status?).to be_truthy }
    end

    context do
      before{ subject.wait_for_status = 'red' }
      specify{ expect(subject.wait_for_status).to eq('red') }
      specify{ expect(subject.wait_for_status?).to be_truthy }
    end
  end

  describe '#wait_for_status_timeout' do
    specify{ expect{ subject.wait_for_status_timeout = :invalid_value }.to raise_error(Optionable::Invalid) }

    context do
      before{ subject.wait_for_status_timeout = nil }
      specify{ expect(subject.wait_for_status_timeout).to be_nil }
      specify{ expect(subject.wait_for_status_timeout?).to be_falsy }
    end

    context do
      before{ subject.wait_for_status_timeout = 5000 }
      specify{ expect(subject.wait_for_status_timeout).to eq(5000) }
      specify{ expect(subject.wait_for_status_timeout?).to be_truthy }
    end

    context do
      before{ subject.wait_for_status_timeout = '1s' }
      specify{ expect(subject.wait_for_status_timeout).to eq('1s') }
      specify{ expect(subject.wait_for_status_timeout?).to be_truthy }
    end
  end

  describe '#refresh' do
    specify{ expect{ subject.refresh = nil }.to raise_error(Optionable::Invalid) }
    specify{ expect{ subject.refresh = :invalid_value }.to raise_error(Optionable::Invalid) }

    context do
      before{ subject.refresh = true }
      specify{ expect(subject.refresh).to eq(true) }
      specify{ expect(subject.refresh?).to be_truthy }
    end

    context do
      before{ subject.refresh = false }
      specify{ expect(subject.refresh).to eq(false) }
      specify{ expect(subject.refresh?).to be_falsy }
    end
  end

  describe '#connection_per_thread' do
    specify{ expect{ subject.connection_per_thread = nil }.to raise_error(Optionable::Invalid) }
    specify{ expect{ subject.connection_per_thread = :invalid_value }.to raise_error(Optionable::Invalid) }

    context do
      before{ subject.connection_per_thread = true }
      specify{ expect(subject.connection_per_thread).to eq(true) }
      specify{ expect(subject.connection_per_thread?).to be_truthy }
    end

    context do
      before{ subject.connection_per_thread = false }
      specify{ expect(subject.connection_per_thread).to eq(false) }
      specify{ expect(subject.connection_per_thread?).to be_falsy }
    end
  end

  describe '#dynamic_scripting' do
    specify{ expect{ subject.dynamic_scripting = nil }.to raise_error(Optionable::Invalid) }
    specify{ expect{ subject.dynamic_scripting = :invalid_value }.to raise_error(Optionable::Invalid) }

    context do
      before{ subject.dynamic_scripting = true }
      specify{ expect(subject.dynamic_scripting).to eq(true) }
      specify{ expect(subject.dynamic_scripting?).to be_truthy }
    end

    context do
      before{ subject.dynamic_scripting = false }
      specify{ expect(subject.dynamic_scripting).to eq(false) }
      specify{ expect(subject.dynamic_scripting?).to be_falsy }
    end
  end

  describe '#index_namespace' do
    specify{ expect{ subject.index_namespace = false }.to raise_error(Optionable::Invalid) }

    context do
      before{ subject.index_namespace = nil }
      specify{ expect(subject.index_namespace).to be_nil }
      specify{ expect(subject.index_namespace?).to be_falsy }
    end

    context do
      before{ subject.index_namespace = :namespace }
      specify{ expect(subject.index_namespace).to eq(:namespace) }
      specify{ expect(subject.index_namespace?).to be_truthy }
    end

    context do
      before{ subject.index_namespace = 'namespace' }
      specify{ expect(subject.index_namespace).to eq('namespace') }
      specify{ expect(subject.index_namespace?).to be_truthy }
    end
  end

  describe '#almost_expire_threshold' do
    specify{ expect{ subject.almost_expire_threshold = nil }.to raise_error(Optionable::Invalid) }
    specify{ expect{ subject.almost_expire_threshold = 1.4 }.to raise_error(Optionable::Invalid) }
    specify{ expect{ subject.almost_expire_threshold = :invalid_value }.to raise_error(Optionable::Invalid) }

    context do
      before{ subject.almost_expire_threshold = 3000 }
      specify{ expect(subject.almost_expire_threshold).to eq(3000) }
      specify{ expect(subject.almost_expire_threshold?).to be_truthy }
    end
  end

  describe '#load!' do
    let(:config_file){ "#{root}/spec/fixtures/config/rubberry.yml" }

    context 'for default environment' do
      before{ subject.load!(config_file) }

      specify{ expect(subject.index).to eq(OpenStruct.new(number_of_shards: 3, number_of_replicas: 3)) }
      specify{ expect(subject.client).to eq(OpenStruct.new(hosts: ['http://localhost:9200'])) }
      specify{ expect(subject.query_mode).to eq(:must) }
      specify{ expect(subject.filter_mode).to eq(:and) }
      specify{ expect(subject.post_filter_mode).to be_nil }
      specify{ expect(subject.wait_for_status).to eq('yellow') }
      specify{ expect(subject.wait_for_status_timeout).to eq('30s') }
      specify{ expect(subject.refresh).to be_truthy }
      specify{ expect(subject.connection_per_thread).to be_truthy }
      specify{ expect(subject.dynamic_scripting).to be_falsy }
      specify{ expect(subject.index_namespace).to eq('test') }
      specify{ expect(subject.almost_expire_threshold).to eq(5000) }
    end

    context 'for development environment' do
      before{ subject.load!(config_file, 'development') }

      specify{ expect(subject.index).to eq(OpenStruct.new(number_of_shards: 3, number_of_replicas: 3)) }
      specify{ expect(subject.client).to eq(OpenStruct.new(hosts: ['http://localhost:9200'])) }
      specify{ expect(subject.query_mode).to eq(:must) }
      specify{ expect(subject.filter_mode).to eq(:and) }
      specify{ expect(subject.post_filter_mode).to be_nil }
      specify{ expect(subject.wait_for_status).to eq('green') }
      specify{ expect(subject.wait_for_status_timeout).to eq('30s') }
      specify{ expect(subject.refresh).to be_falsy }
      specify{ expect(subject.connection_per_thread).to be_truthy }
      specify{ expect(subject.dynamic_scripting).to be_truthy }
      specify{ expect(subject.index_namespace).to eq('test') }
      specify{ expect(subject.almost_expire_threshold).to eq(5000) }
    end

    context 'when file has invalid values' do
      let(:config_file){ "#{root}/spec/fixtures/config/invalid.yml" }

      specify{ expect{ subject.load!(config_file) }.to raise_error(Optionable::Invalid) }
    end
  end
end
