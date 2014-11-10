require 'spec_helper'

describe Rubberry::Commands::Create do
  before do
    stub_model('User') do
      mappings do
        field :name
      end
    end
    User.index.create
  end

  after{ User.index.delete }

  let(:user){ User.new(name: 'Undr') }

  describe '#request' do
    let(:options){ {} }

    subject{ Rubberry::Commands::Create.new(user, options).request }

    specify{ expect(subject).to eq(index: 'test_users', type: 'user', body: { 'name' => 'Undr' }, refresh: true) }

    context 'with options' do
      let(:time){ Time.now }
      let(:options){ {
        refresh: false,
        consistency: :all,
        replication: :sync,
        timestamp: time,
        timeout: '2s',
        ttl: '8w'
      } }

      specify{ expect(subject).to eq(
        index: 'test_users',
        type: 'user',
        body: { 'name' => 'Undr' },
        refresh: false,
        consistency: :all,
        replication: :sync,
        timestamp: time,
        timeout: '2s',
        ttl: '8w'
      ) }
    end

    context 'with document ttl' do
      before do
        allow(User).to receive(:document_ttl).and_return('1w')
        allow(User).to receive(:document_ttl?).and_return(true)
      end

      specify{ expect(subject).to eq(
        index: 'test_users', type: 'user', body: { 'name' => 'Undr' }, refresh: true, ttl: '1w'
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

    context 'when document is not creatable' do
      before{ Rubberry::Commands::Create.new(user, options).perform }

      specify{ expect(user).to be_persisted }
      specify{ expect(user.name).to eq('Undr') }
      specify{ expect(user.changed?).to be_falsy }
      specify{ expect(user._id).not_to be_nil }
      specify{ expect(user._version).not_to be_nil }
      specify{ expect(User.find(user._id)).not_to be_nil }
    end

    context 'when document is not creatable' do
      before{ allow(user).to receive(:creatable?).and_return(false) }

      specify{ expect(Rubberry::Commands::Create.new(user, options).perform).to be_falsy }

      context do
        before{ Rubberry::Commands::Create.new(user, options).perform }
        specify{ expect(user).not_to be_persisted }
        specify{ expect(user.name).to eq('Undr') }
        specify{ expect(user.changed?).to be_truthy }
        specify{ expect(user._id).to be_nil }
        specify{ expect(user._version).to be_nil }
        specify{ expect(User.find(user._id)).to be_nil }
      end
    end
  end
end
