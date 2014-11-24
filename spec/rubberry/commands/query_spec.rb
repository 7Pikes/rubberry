require 'spec_helper'

describe Rubberry::Commands::Query, index_model: SomeUser do
  describe '#request' do
    let(:ctx){ SomeUser.context }

    subject{ Rubberry::Commands::Query.new(ctx).request }

    context 'without query' do
      specify{ expect(subject).to eq(ctx.request) }
    end

    context 'with query' do
      let(:ctx){ SomeUser.filter(handsome: true) }

      specify{ expect(subject).to eq(ctx.request) }
    end
  end

  describe '#perform' do
    let(:ctx){ SomeUser.context }

    subject{ Rubberry::Commands::Query.new(ctx).perform }

    before do
      SomeUser.create(name: 'Undr')
      SomeUser.create(name: 'Ammy')
      SomeUser.create(name: 'Arny', handsome: false)
      SomeUser.create(name: 'Ron', handsome: false)
    end

    context 'without query' do
      specify{ expect(subject['hits']['hits'].map{|d| d['_source']}).to eq([
        { 'name' => 'Undr', 'handsome' => true, 'counter' => 0 },
        { 'name' => 'Ammy', 'handsome' => true, 'counter' => 0 },
        { 'name' => 'Arny', 'handsome' => false, 'counter' => 0 },
        { 'name' => 'Ron', 'handsome' => false, 'counter' => 0 }
      ]) }
    end

    context 'with query' do
      let(:ctx){ SomeUser.filter{ handsome == true } }

      specify{ expect(subject['hits']['hits'].map{|d| d['_source']}).to eq([
        { 'name' => 'Undr', 'handsome' => true, 'counter' => 0 },
        { 'name' => 'Ammy', 'handsome' => true, 'counter' => 0 }
      ]) }
    end

    context 'when index missing' do
      let(:ctx){ User.context }
      specify{ expect(subject).to eq({}) }
    end
  end
end
