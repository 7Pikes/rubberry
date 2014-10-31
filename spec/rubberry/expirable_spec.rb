require 'spec_helper'

describe Rubberry::Expirable do
  before do
    stub_model('UserWithTTL') do
      document_ttl '2s'

      mappings do
        field :name
      end
    end

    stub_model('UserWithTimestamp') do
      mappings do
        _timestamp enabled: true, store: true
        field :name
      end
    end

    stub_model('User') do
      mappings do
        field :name
      end
    end

    User.index.create
    UserWithTTL.index.create
    UserWithTimestamp.index.create
  end

  after do
    User.index.delete
    UserWithTTL.index.delete
    UserWithTimestamp.index.delete
  end

  describe '#_ttl' do
    subject{ UserWithTTL.create(name: 'Undr') }

    specify{ expect(subject._ttl).to be < (2 * 1000) }
    specify{ expect(subject._ttl).to be == subject._ttl }

    context 'when model that does not have TTL' do
      subject{ User.create(name: 'Undr') }
      specify{ expect(subject._ttl).to be_nil }
    end
  end

  describe '#_ttl?' do
    subject{ UserWithTTL.create(name: 'Undr') }

    specify{ expect(subject._ttl?).to be_truthy }

    context 'when model that does not have TTL' do
      subject{ User.create(name: 'Undr') }
      specify{ expect(subject._ttl?).to be_falsy }
    end
  end

  describe '#_ttl!' do
    subject{ UserWithTTL.create(name: 'Undr') }

    specify{ expect(subject._ttl!).to be < (2 * 1000) }
    specify{ expect(subject._ttl!).to be >= subject._ttl! }

    context 'when model that does not have TTL' do
      subject{ User.create(name: 'Undr') }
      specify{ expect(subject._ttl!).to be_nil }
    end
  end

  describe '#_timestamp' do
    subject{ UserWithTimestamp.create(name: 'Undr') }

    specify{ expect(subject._timestamp).to be_instance_of(Time) }
    specify{ expect(subject._timestamp).to be < Time.now }
    specify{ expect(subject._timestamp).to be == subject._timestamp }

    context 'when model that does not have timestamp' do
      subject{ User.create(name: 'Undr') }
      specify{ expect(subject._timestamp).to be_nil }
    end
  end

  describe '#_timestamp?' do
    subject{ UserWithTimestamp.create(name: 'Undr') }

    specify{ expect(subject._timestamp?).to be_truthy }

    context 'when model that does not have timestamp' do
      subject{ User.create(name: 'Undr') }
      specify{ expect(subject._timestamp?).to be_falsy }
    end
  end

  describe '#_timestamp!' do
    subject{ UserWithTimestamp.create(name: 'Undr') }

    specify{ expect(subject._timestamp!).to be_instance_of(Time) }
    specify{ expect(subject._timestamp!).to be < Time.now }
    specify{ expect(subject._timestamp!).to be == subject._timestamp! }

    context 'when model that does not have timestamp' do
      subject{ User.create(name: 'Undr') }
      specify{ expect(subject._timestamp!).to be_nil }
    end
  end

  describe '#almost_expired?' do
    let(:ttl){ 6000 }

    subject{ UserWithTTL.create(name: 'Undr') }

    before do
      Rubberry.config.almost_expire_threshold = 5000
      allow(subject).to receive(:underscored_fields).and_return('_ttl' => ttl)
    end

    specify{ expect(subject).not_to be_almost_expired }

    context 'when ttl less than thrashold' do
      let(:ttl){ 4000 }
      specify{ expect(subject).to be_almost_expired }
    end

    context 'when ttl less than 0' do
      let(:ttl){ -1000 }
      specify{ expect(subject).to be_almost_expired }
    end
  end

  describe '#expired?' do
    let(:ttl){ 6000 }

    subject{ UserWithTTL.create(name: 'Undr') }

    before do
      Rubberry.config.almost_expire_threshold = 5000
      allow(subject).to receive(:underscored_fields).and_return('_ttl' => ttl)
    end

    specify{ expect(subject).not_to be_expired }

    context 'when ttl less than thrashold' do
      let(:ttl){ 4000 }
      specify{ expect(subject).not_to be_expired }
    end

    context 'when ttl less than 0' do
      let(:ttl){ -1000 }
      specify{ expect(subject).to be_expired }
    end
  end
end
