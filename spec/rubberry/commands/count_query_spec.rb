require 'spec_helper'

describe Rubberry::Commands::CountQuery, index_model: SomeUser do
  describe '#request' do
    let(:ctx){ SomeUser.context }

    subject{ Rubberry::Commands::CountQuery.new(ctx).request }

    context 'without query' do
      specify{ expect(subject).to eq(ctx.count_query_request) }
    end

    context 'with query' do
      let(:ctx){ SomeUser.filter(handsome: true) }

      specify{ expect(subject).to eq(ctx.count_query_request) }
    end
  end

  describe '#perform' do
    let(:ctx){ SomeUser.context }

    subject{ Rubberry::Commands::CountQuery.new(ctx).perform }

    before do
      SomeUser.create(name: 'Undr')
      SomeUser.create(name: 'Ammy')
      SomeUser.create(name: 'Arny', handsome: false)
      SomeUser.create(name: 'Ron', handsome: false)
    end

    context 'without query' do
      specify{ expect(subject).to eq(4) }
    end

    context 'with query' do
      let(:ctx){ SomeUser.filter{ handsome == true } }

      specify{ expect(subject).to eq(2) }
    end

    context 'when none' do
      let(:ctx){ SomeUser.none }
      specify{ expect(subject).to eq(0) }
    end

    context 'when index missing' do
      let(:ctx){ User.context }
      specify{ expect(subject).to eq(0) }
    end
  end
end
