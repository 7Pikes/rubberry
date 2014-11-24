require 'spec_helper'

describe Rubberry::Commands::DeleteAll, index_model: SomeUser do
  describe '#request' do
    let(:ctx){ SomeUser.context }
    let(:options){ {} }

    subject{ Rubberry::Commands::DeleteAll.new(ctx, options).request }

    context 'without query' do
      specify{ expect(subject).to eq(ctx.delete_all_request) }
    end

    context 'with query' do
      let(:ctx){ SomeUser.filter(handsome: true) }
      specify{ expect(subject).to eq(ctx.delete_all_request) }
    end

    context 'with request options' do
      let(:options){ { consistency: :one, replication: :sync, timeout: '2s' } }
      specify{ expect(subject).to eq(ctx.delete_all_request.merge(
        consistency: :one, replication: :sync, timeout: '2s'
      )) }
    end

    context 'with invalid value for option' do
      let(:options){ { timeout: true } }
      specify{ expect{ subject }.to raise_error(Optionable::Invalid) }
    end

    context 'with invalid option' do
      let(:options){ { lalala: 'lalala' } }
      specify{ expect{ subject }.to raise_error(Optionable::Unknown) }
    end
  end

  describe '#perform' do
    let(:ctx){ SomeUser.context }

    subject{ Rubberry::Commands::DeleteAll.new(ctx).perform }

    before do
      SomeUser.create(name: 'Undr')
      SomeUser.create(name: 'Ammy')
      SomeUser.create(name: 'Arny', handsome: false)
      SomeUser.create(name: 'Ron', handsome: false)
    end

    context 'without query' do
      specify{ expect{ subject }.to change{ SomeUser.count }.from(4).to(0) }
    end

    context 'with query' do
      let(:ctx){ SomeUser.filter{ handsome == true } }

      specify{ expect{ subject }.to change{ SomeUser.count }.from(4).to(2) }

      context do
        before{ subject }
        specify{ expect(ctx.count).to eq(0) }
      end
    end
  end
end
