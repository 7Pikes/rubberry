require 'spec_helper'

describe Rubberry::Commands::CountQuery do
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

    subject{ Rubberry::Commands::CountQuery.new(ctx).request }

    context 'without query' do
      specify{ expect(subject).to eq(ctx.count_query_request) }
    end

    context 'with query' do
      let(:ctx){ User.filter(handsome: true) }

      specify{ expect(subject).to eq(ctx.count_query_request) }
    end
  end

  describe '#perform' do
    let(:ctx){ User.context }

    subject{ Rubberry::Commands::CountQuery.new(ctx).perform }

    before do
      User.create(name: 'Undr')
      User.create(name: 'Ammy')
      User.create(name: 'Arny', handsome: false)
      User.create(name: 'Ron', handsome: false)
    end

    context 'without query' do
      specify{ expect(subject).to eq(4) }
    end

    context 'with query' do
      let(:ctx){ User.filter{ handsome == true } }

      specify{ expect(subject).to eq(2) }
    end

    context 'when none' do
      let(:ctx){ User.none }
      specify{ expect(subject).to eq(0) }
    end

    context 'when index missing' do
      let(:ctx){ UserWithoutIndex.context }
      specify{ expect(subject).to eq(0) }
    end
  end
end
