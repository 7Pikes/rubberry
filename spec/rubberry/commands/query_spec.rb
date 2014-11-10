require 'spec_helper'

describe Rubberry::Commands::Query do
  before do
    stub_model('UserWithoutIndex') do
       mappings do
        field :name
        field :handsome, type: 'boolean', default: true
      end
    end

    stub_model('User') do
      mappings do
        field :name
        field :handsome, type: 'boolean', default: true
      end
    end
    User.index.create
  end

  after{ User.index.delete }

  describe '#request' do
    let(:ctx){ User.context }

    subject{ Rubberry::Commands::Query.new(ctx).request }

    context 'without query' do
      specify{ expect(subject).to eq(ctx.request) }
    end

    context 'with query' do
      let(:ctx){ User.filter(handsome: true) }

      specify{ expect(subject).to eq(ctx.request) }
    end
  end

  describe '#perform' do
    let(:ctx){ User.context }

    subject{ Rubberry::Commands::Query.new(ctx).perform }

    before do
      User.create(name: 'Undr')
      User.create(name: 'Ammy')
      User.create(name: 'Arny', handsome: false)
      User.create(name: 'Ron', handsome: false)
    end

    context 'without query' do
      specify{ expect(subject['hits']['hits'].map{|d| d['_source']}).to eq([
        { 'name' =>  'Undr', 'handsome' =>  true },
        { 'name' =>  'Ammy', 'handsome' =>  true },
        { 'name' =>  'Arny', 'handsome' =>  false},
        { 'name' =>  'Ron', 'handsome' =>  false}
      ]) }
    end

    context 'with query' do
      let(:ctx){ User.filter{ handsome == true } }

      specify{ expect(subject['hits']['hits'].map{|d| d['_source']}).to eq([
        { 'name' =>  'Undr', 'handsome' =>  true },
        { 'name' =>  'Ammy', 'handsome' =>  true }
      ]) }
    end

    context 'when index missing' do
      let(:ctx){ UserWithoutIndex.context }
      specify{ expect(subject).to eq({}) }
    end
  end
end
