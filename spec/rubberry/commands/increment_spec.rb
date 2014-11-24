require 'spec_helper'

describe Rubberry::Commands::Increment, index_model: User do
  let(:user){ User.create(name: 'Undr') }

  describe '#request_options' do
    let(:options){ {} }

    subject{ Rubberry::Commands::Increment.new(user, options).request_options }

    specify{ expect(subject).to eq(refresh: true) }

    context 'with request options' do
      let(:time){ Time.now }
      let(:options){ {
        atomic: true,
        counters: :counter1,
        operation: '+',

        refresh: false,
        retry_on_conflict: 3,
        consistency: :all,
        replication: :sync,
        timestamp: time,
        timeout: '2s',
        ttl: '8w'
      } }

      specify{ expect(subject).to eq(
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
    before{ Rubberry::Commands::Increment.new(user, options).perform }

    context 'atomic operation' do
      let(:options){ { counters: [:counter1, :counter2], atomic: true } }
      specify{ expect(user).to be_persisted }
      specify{ expect(user.counter1).to eq(1) }
      specify{ expect(user.reload.counter1).to eq(1) }
      specify{ expect(user.counter2).to eq(1) }
      specify{ expect(user.reload.counter2).to eq(1) }
    end

    context 'non atomic operation' do
      let(:options){ { counters: [:counter1, :counter2], atomic: false } }
      specify{ expect(user).to be_persisted }
      specify{ expect(user.counter1).to eq(1) }
      specify{ expect(user.reload.counter1).to eq(1) }
      specify{ expect(user.counter2).to eq(1) }
      specify{ expect(user.reload.counter2).to eq(1) }
    end
  end
end
