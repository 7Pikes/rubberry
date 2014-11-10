require 'spec_helper'

describe Rubberry::Commands::Atomic::Increment do
  before do
    stub_model('User') do
      mappings do
        field :name
        field :counter1, type: 'integer', default: 0
        field :counter2, type: 'integer'
      end
    end
    User.index.create
  end

  let(:user){ User.create(name: 'Undr') }

  after{ User.index.delete }

  describe '#request' do
    subject{ Rubberry::Commands::Atomic::Increment.new(User, options).request }

    context do
      let(:options){ { id: user._id, counters: :counter1, operation: '+' } }

      specify{ expect(subject).to eq(
        index: 'test_users',
        type: 'user',
        body: {
          script: 'if(isdef ctx._source.counter1){ ctx._source.counter1 += 1 } else { ctx._source.counter1 = 1 }'
        },
        id: user._id,
        refresh: true
      ) }
    end

    context 'as decrement by 10' do
      let(:options){ { id: user._id, counters: { counter1: 10 }, operation: '-' } }

      specify{ expect(subject).to eq(
        index: 'test_users',
        type: 'user',
        body: {
          script: 'if(isdef ctx._source.counter1){ ctx._source.counter1 += -10 } else { ctx._source.counter1 = -10 }'
        },
        id: user._id,
        refresh: true
      ) }
    end

    context 'with multi counters as array' do
      let(:options){ { id: user._id, counters: [:counter1, :counter2], operation: '+' } }

      specify{ expect(subject).to eq(
        index: 'test_users',
        type: 'user',
        body: {
          script: 'if(isdef ctx._source.counter1){ ctx._source.counter1 += 1 } else { ctx._source.counter1 = 1 }; ' \
            'if(isdef ctx._source.counter2){ ctx._source.counter2 += 1 } else { ctx._source.counter2 = 1 }'
        },
        id: user._id,
        refresh: true
      ) }
    end

    context 'with multi counters as hash' do
      let(:options){ { id: user._id, counters: { counter1: 5, counter2: 10 }, operation: '+' } }

      specify{ expect(subject).to eq(
        index: 'test_users',
        type: 'user',
        body: {
          script: 'if(isdef ctx._source.counter1){ ctx._source.counter1 += 5 } else { ctx._source.counter1 = 5 }; ' \
            'if(isdef ctx._source.counter2){ ctx._source.counter2 += 10 } else { ctx._source.counter2 = 10 }'
        },
        id: user._id,
        refresh: true
      ) }
    end

    context 'with request options' do
      let(:time){ Time.now }
      let(:options){ {
        id: user._id,
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
        index: 'test_users',
        type: 'user',
        body: {
          script: 'if(isdef ctx._source.counter1){ ctx._source.counter1 += 1 } else { ctx._source.counter1 = 1 }'
        },
        id: user._id,
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
    before{ Rubberry::Commands::Atomic::Increment.new(User, options).perform }

    context '- operation' do
      let(:options){ { id: user._id, counters: [:counter1, :counter2], operation: '-' } }
      specify{ expect(user.reload.counter1).to eq(-1) }
      specify{ expect(user.reload.counter2).to eq(-1) }
    end

    context '+ operation' do
      let(:options){ { id: user._id, counters: [:counter1, :counter2], operation: '+' } }
      specify{ expect(user.reload.counter1).to eq(1) }
      specify{ expect(user.reload.counter2).to eq(1) }
    end
  end
end
