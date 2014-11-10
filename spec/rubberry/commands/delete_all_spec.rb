require 'spec_helper'

describe Rubberry::Commands::DeleteAll do
  before do
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
    let(:options){ {} }

    subject{ Rubberry::Commands::DeleteAll.new(ctx, options).request }

    context 'without query' do
      specify{ expect(subject).to eq(ctx.delete_all_request) }
    end

    context 'with query' do
      let(:ctx){ User.filter(handsome: true) }
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
    let(:ctx){ User.context }

    subject{ Rubberry::Commands::DeleteAll.new(ctx).perform }

    before do
      User.create(name: 'Undr')
      User.create(name: 'Ammy')
      User.create(name: 'Arny', handsome: false)
      User.create(name: 'Ron', handsome: false)
    end

    context 'without query' do
      specify{ expect{ subject }.to change{ User.count }.from(4).to(0) }
    end

    context 'with query' do
      let(:ctx){ User.filter{ handsome == true } }

      specify{ expect{ subject }.to change{ User.count }.from(4).to(2) }

      context do
        before{ subject }
        specify{ expect(ctx.count).to eq(0) }
      end
    end
  end
end
