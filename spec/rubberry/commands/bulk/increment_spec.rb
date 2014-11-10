require 'spec_helper'

describe Rubberry::Commands::Bulk::Increment do
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
    subject{ Rubberry::Commands::Bulk::Increment.new(user, options).request }

    context do
      let(:options){ { id: user._id, counters: :counter1, operation: '+' } }

      specify{ expect(subject).to eq('update' => {
        _index: 'test_users',
        _type: 'user',
        _id: user._id,
        data: {
          script: 'if(isdef ctx._source.counter1){ ctx._source.counter1 += 1 } else { ctx._source.counter1 = 1 }'
        }
      }) }
    end

    context 'as decrement by 10' do
      let(:options){ { id: user._id, counters: { counter1: 10 }, operation: '-' } }

      specify{ expect(subject).to eq('update' => {
        _index: 'test_users',
        _type: 'user',
        _id: user._id,
        data: {
          script: 'if(isdef ctx._source.counter1){ ctx._source.counter1 += -10 } else { ctx._source.counter1 = -10 }'
        }
      }) }
    end

    context 'with multi counters as array' do
      let(:options){ { id: user._id, counters: [:counter1, :counter2], operation: '+' } }

      specify{ expect(subject).to eq('update' => {
        _index: 'test_users',
        _type: 'user',
        _id: user._id,
        data: {
          script: 'if(isdef ctx._source.counter1){ ctx._source.counter1 += 1 } else { ctx._source.counter1 = 1 }; ' \
            'if(isdef ctx._source.counter2){ ctx._source.counter2 += 1 } else { ctx._source.counter2 = 1 }'
        }
      }) }
    end

    context 'with multi counters as hash' do
      let(:options){ { id: user._id, counters: { counter1: 5, counter2: 10 }, operation: '+' } }

      specify{ expect(subject).to eq('update' => {
        _index: 'test_users',
        _type: 'user',
        _id: user._id,
        data: {
          script: 'if(isdef ctx._source.counter1){ ctx._source.counter1 += 5 } else { ctx._source.counter1 = 5 }; ' \
            'if(isdef ctx._source.counter2){ ctx._source.counter2 += 10 } else { ctx._source.counter2 = 10 }'
        }
      }) }
    end

    context 'with request options' do
      let(:time){ Time.now }
      let(:options){ {
        id: user._id,
        counters: :counter1,
        operation: '+',

        retry_on_conflict: 3,
        timestamp: time,
        ttl: '8w'
      } }

      specify{ expect(subject).to eq('update' => {
        _index: 'test_users',
        _type: 'user',
        _id: user._id,
        data: {
          script: 'if(isdef ctx._source.counter1){ ctx._source.counter1 += 1 } else { ctx._source.counter1 = 1 }'
        },
        _retry_on_conflict: 3,
        timestamp: time,
        ttl: '8w'
      }) }
    end

    context 'with invalid value for option' do
      let(:options){ { operation: 'lalala' } }
      specify{ expect{ subject }.to raise_error(Optionable::Invalid) }
    end

    context 'with invalid option' do
      let(:options){ { lalala: 'lalala' } }
      specify{ expect{ subject }.to raise_error(Optionable::Unknown) }
    end
  end

  describe '#perform' do
    let(:bulk){ [] }
    let(:options){ { id: user._id, counters: [:counter1, :counter2], operation: '+' } }
    let!(:command){ Rubberry::Commands::Bulk::Increment.new(user, options) }

    before{ allow(Rubberry).to receive(:bulk).and_return(bulk) }

    context 'when document is incrementable' do
      specify{ expect(command.perform).to be_truthy }

      context do
        before{ command.perform }
        specify{ expect(Rubberry.bulk).to eq([command]) }
        specify{ expect(user).to be_bulked }
        specify{ expect(user.counter1).to eq(0) }
        specify{ expect(user.counter2).to be_nil }
      end
    end

    context 'when document is not incrementable' do
      before{ allow(user).to receive(:destroyable?).and_return(false) }

      specify{ expect(command.perform).to be_falsy }

      context do
        before{ command.perform }
        specify{ expect(Rubberry.bulk).to eq([]) }
        specify{ expect(user).not_to be_bulked }
        specify{ expect(user.counter1).to eq(0) }
        specify{ expect(user.counter2).to be_nil }
      end
    end
  end
end
