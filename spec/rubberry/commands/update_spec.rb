require 'spec_helper'

describe Rubberry::Commands::Update, index_model: Events::Info do
  let(:event){ Events::Info.create(name: 'page_view', message: 'Ok!') }

  describe '#request' do
    let(:options){ {} }

    before{ event.message = 'Done!' }

    subject{ Rubberry::Commands::Update.new(event, options).request }

    specify{ expect(subject).to eq(
      index: 'test_user_events', type: 'info', id: event._id, body: { doc: { 'message' => 'Done!' } }, refresh: true
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
        index: 'test_user_events',
        type: 'info',
        id: event._id,
        body: { doc: { 'message' => 'Done!' } },
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
    let(:reloaded_event){ event.reload }
    let(:options){ {} }
    let!(:version){ event._version }

    before{ event.message = 'Done!' }

    context 'when document is updatable' do
      before{ Rubberry::Commands::Update.new(event, options).perform }

      specify{ expect(event.message).to eq('Done!') }
      specify{ expect(event.changed?).to be_falsy }
      specify{ expect(event._version).to eq(version + 1) }
      specify{ expect(reloaded_event._version).to eq(version + 1) }
      specify{ expect(reloaded_event.message).to eq('Done!') }
    end

    context 'when document is not updatable' do
      before{ allow(event).to receive(:updatable?).and_return(false) }

      specify{ expect(Rubberry::Commands::Update.new(event, options).perform).to be_falsy }

      context do
        before{ Rubberry::Commands::Update.new(event, options).perform }
        specify{ expect(event.message).to eq('Done!') }
        specify{ expect(event.changed?).to be_truthy }
        specify{ expect(event._version).to eq(version) }
        specify{ expect(reloaded_event._version).to eq(version) }
        specify{ expect(reloaded_event.message).to eq('Ok!') }
      end
    end
  end
end
