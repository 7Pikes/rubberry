require 'spec_helper'

describe Rubberry::Commands::Bulk::Update, index_model: UserEvent do
  let(:user){ UserEvent.create(name: 'Undr').tap{|u| u.name = 'Arny' } }

  describe '#request' do
    subject{ Rubberry::Commands::Bulk::Update.new(user, options).request }

    context do
      let(:options){ {} }

      specify{ expect(subject).to eq('update' => {
        _index: 'test_user_events',
        _type: 'user_event',
        _id: user._id,
        data: { doc: { 'name' => 'Arny' } }
      }) }
    end



    context 'with request options' do
      let(:time){ Time.now }
      let(:options){ {
        retry_on_conflict: 3,
        timestamp: time,
        ttl: '8w'
      } }

      specify{ expect(subject).to eq('update' => {
        _index: 'test_user_events',
        _type: 'user_event',
        _id: user._id,
        data: { doc: { 'name' => 'Arny' } },
        _retry_on_conflict: 3,
        timestamp: time,
        ttl: '8w'
      }) }
    end

    context 'with invalid value for option' do
      let(:options){ { timestamp: true } }
      specify{ expect{ subject }.to raise_error(Optionable::Invalid) }
    end

    context 'with invalid option' do
      let(:options){ { lalala: 'lalala' } }
      specify{ expect{ subject }.to raise_error(Optionable::Unknown) }
    end
  end

  describe '#perform' do
    let(:bulk){ [] }
    let(:options){ { } }
    let!(:command){ Rubberry::Commands::Bulk::Update.new(user, options) }

    before{ allow(Rubberry).to receive(:bulk).and_return(bulk) }

    context 'when document is updatable' do
      specify{ expect(command.perform).to be_truthy }

      context do
        before{ command.perform }
        specify{ expect(Rubberry.bulk).to eq([command]) }
        specify{ expect(user).to be_bulked }
        specify{ expect(user).to be_changed }
      end
    end

    context 'when document is not updatable' do
      before{ allow(user).to receive(:updatable?).and_return(false) }

      specify{ expect(command.perform).to be_falsy }

      context do
        before{ command.perform }
        specify{ expect(Rubberry.bulk).to eq([]) }
        specify{ expect(user).not_to be_bulked }
        specify{ expect(user).to be_changed }
      end
    end
  end
end
