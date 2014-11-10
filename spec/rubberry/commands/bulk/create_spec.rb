require 'spec_helper'

describe Rubberry::Commands::Bulk::Create do
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
  let(:options){ {} }

  describe '#request' do
    subject{ Rubberry::Commands::Bulk::Create.new(user, options).request }

    specify{ expect(subject).to eq('create' => { _index: 'test_users', _type: 'user', data: { 'name' => 'Undr' } }) }

    context 'with options' do
      let(:time){ Time.now }
      let(:options){ { timestamp: time, ttl: '8w' } }

      specify{ expect(subject).to eq('create' => {
        _index: 'test_users',
        _type: 'user',
        data: { 'name' => 'Undr' },
        timestamp: time,
        ttl: '8w'
      }) }
    end

    context 'with document ttl' do
      before do
        allow(User).to receive(:document_ttl).and_return('1w')
        allow(User).to receive(:document_ttl?).and_return(true)
      end

      specify{ expect(subject).to eq('create' => {
        _index: 'test_users', _type: 'user', data: { 'name' => 'Undr' }, ttl: '1w'
      }) }
    end

    context 'with invalid value for option' do
      let(:options){ { ttl: true } }
      specify{ expect{ subject }.to raise_error(Optionable::Invalid) }
    end

    context 'with invalid option' do
      let(:options){ { lalala: 'lalala' } }
      specify{ expect{ subject }.to raise_error(Optionable::Unknown) }
    end
  end

  describe '#perform' do
    let(:bulk){ [] }
    let(:command){ Rubberry::Commands::Bulk::Create.new(user, options) }

    before{ allow(Rubberry).to receive(:bulk).and_return(bulk) }

    context 'when document is creatable' do
      specify{ expect(command.perform).to be_truthy }

      context do
        before{ command.perform }

        specify{ expect(Rubberry.bulk).to eq([command]) }
        specify{ expect(user).to be_bulked }
        specify{ expect(user).to be_new_record }
        specify{ expect(user.name).to eq('Undr') }
        specify{ expect(user.changed?).to be_truthy }
        specify{ expect(user._id).to be_nil }
        specify{ expect(user._version).to be_nil }
      end
    end

    context 'when document is not creatable' do
      before{ allow(user).to receive(:creatable?).and_return(false) }

      specify{ expect(command.perform).to be_falsy }

      context do
        before{ command.perform }

        specify{ expect(Rubberry.bulk).to eq([]) }
        specify{ expect(user).not_to be_bulked }
        specify{ expect(user).to be_new_record }
        specify{ expect(user.name).to eq('Undr') }
        specify{ expect(user.changed?).to be_truthy }
        specify{ expect(user._id).to be_nil }
        specify{ expect(user._version).to be_nil }
      end
    end
  end
end
