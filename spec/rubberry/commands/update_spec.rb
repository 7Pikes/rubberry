require 'spec_helper'

describe Rubberry::Commands::Update do
  before do
    stub_model('User') do
      mappings do
        field :name
        field :nickname
      end
    end
    User.index.create
  end

  after{ User.index.delete }

  let(:user){ User.create(name: 'Undr', nickname: 'Great') }

  describe '#request' do
    let(:options){ {} }

    before{ user.name = 'Arny' }

    subject{ Rubberry::Commands::Update.new(user, options).request }

    specify{ expect(subject).to eq(
      index: 'test_users', type: 'user', id: user._id, body: { doc: { 'name' => 'Arny' } }, refresh: true
    ) }

    context 'with options' do
      let(:time){ Time.now }
      let(:options){ {
        refresh: false,
        retry_on_conflict: 3,
        consistency: :all,
        replication: :sync,
        timestamp: time,
        timeout: '2s',
        ttl: '8w'
      } }

      specify{ expect(subject).to eq(
        index: 'test_users',
        type: 'user',
        id: user._id,
        body: { doc: { 'name' => 'Arny' } },
        refresh: false,
        retry_on_conflict: 3,
        consistency: :all,
        replication: :sync,
        timestamp: time,
        timeout: '2s',
        ttl: '8w'
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
    let(:reloaded_user){ user.reload }
    let(:options){ {} }
    let!(:version){ user._version }

    before{ user.name = 'Arny' }

    context 'when document is updatable' do
      before{ Rubberry::Commands::Update.new(user, options).perform }

      specify{ expect(user.name).to eq('Arny') }
      specify{ expect(user.changed?).to be_falsy }
      specify{ expect(user._version).to eq(version + 1) }
      specify{ expect(reloaded_user._version).to eq(version + 1) }
      specify{ expect(reloaded_user.name).to eq('Arny') }
    end

    context 'when document is not updatable' do
      before{ allow(user).to receive(:updatable?).and_return(false) }

      specify{ expect(Rubberry::Commands::Update.new(user, options).perform).to be_falsy }

      context do
        before{ Rubberry::Commands::Update.new(user, options).perform }
        specify{ expect(user.name).to eq('Arny') }
        specify{ expect(user.changed?).to be_truthy }
        specify{ expect(user._version).to eq(version) }
        specify{ expect(reloaded_user._version).to eq(version) }
        specify{ expect(reloaded_user.name).to eq('Undr') }
      end
    end
  end
end
