require 'spec_helper'

describe Rubberry::Commands::Delete do
  before do
    stub_model('User') do
      mappings do
        field :name
      end
    end
    User.index.create
  end

  after{ User.index.delete }

  let(:user){ User.create(name: 'Undr') }

  describe '#request' do
    let(:options){ {} }

    subject{ Rubberry::Commands::Delete.new(user, options).request }

    specify{ expect(subject).to eq(index: 'test_users', type: 'user', id: user._id, refresh: true) }

    context 'with options' do
      let(:time){ Time.now }
      let(:options){ {
        refresh: false,
        consistency: :all,
        replication: :sync,
        timeout: '2s',
      } }

      specify{ expect(subject).to eq(
        index: 'test_users',
        type: 'user',
        id: user._id,
        refresh: false,
        consistency: :all,
        replication: :sync,
        timeout: '2s',
      ) }
    end

    context 'with invalid value for option' do
      let(:options){ { refresh: 'lalala' } }
      specify{ expect{ subject }.to raise_error(Optionable::Invalid) }
    end

    context 'with invalid option' do
      let(:options){ { lalala: 'lalala' } }
      specify{ expect{ subject }.to raise_error(Optionable::Unknown) }
    end
  end

  describe '#perform' do
    let(:options){ {} }

    context 'when document is destroyable' do
      before{ Rubberry::Commands::Delete.new(user, options).perform }
      specify{ expect(user).to be_destroyed }
      specify{ expect(User.find(user._id)).to be_nil }
    end

    context 'when document is not destroyable' do
      before{ allow(user).to receive(:destroyable?).and_return(false) }

      specify{ expect(Rubberry::Commands::Delete.new(user, options).perform).to be_falsy }

      context do
        before{ Rubberry::Commands::Delete.new(user, options).perform }
        specify{ expect(user).not_to be_destroyed }
        specify{ expect(User.find(user._id)).not_to be_nil }
      end
    end
  end
end
