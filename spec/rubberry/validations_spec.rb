require 'spec_helper'

describe Rubberry::Validations do
  before do
    stub_model('User') do
      mappings do
        field :name
        field :counter, type: 'integer', default: 0
      end
      validates :name, presence: true
    end
    User.index.create
  end

  after{ User.index.delete }

  describe '.create!' do
    context 'create with validation errors' do
      specify{ expect{ User.create!(counter: 2) }.to raise_error(Rubberry::DocumentInvalid) }
    end

    context 'create without validation errors' do
      subject{ User.create!(name: 'Undr') }

      specify{ expect(subject).to be_persisted }
      specify{ expect(subject).to be_instance_of(User) }
    end
  end

  describe '#save' do
    context 'when it is new record' do
      context 'and no validation errors' do
        let(:user){ User.new(name: 'Undr') }

        before{ user.save }

        specify{ expect(user).to be_persisted }
      end

      context 'and has validation errors' do
        let(:user){ User.new(counter: 2) }

        specify{ expect(user.save).to be_falsy }
        specify{ expect{ user.save }.to change{ user.errors } }
      end
    end

    context 'when it is not new record' do
      context 'and no validation errors' do
        let(:user){ User.create(name: 'Undr') }

        before do
          user.name = 'Arny'
          user.save
        end

        specify{ expect(user).to be_persisted }
      end

      context 'and has validation errors' do
        let(:user){ User.create(name: 'Undr') }

        before do
          user.name = nil
          user.save
        end

        specify{ expect(user.save).to be_falsy }
        specify{ expect{ user.save }.to change{ user.errors } }
      end
    end
  end

  describe '#save!' do
    context 'when it is new record' do
      context 'and no validation errors' do
        let(:user){ User.new(name: 'Undr') }

        specify{ expect{ user.save! }.not_to raise_error }
      end

      context 'and has validation errors' do
        let(:user){ User.new(counter: 2) }

        specify{ expect{ user.save! }.to raise_error(Rubberry::DocumentInvalid) }
      end
    end

    context 'when it is not new record' do
      context 'and no validation errors' do
        let(:user){ User.create(name: 'Undr') }

        before{ user.name = 'Arny' }

        specify{ expect{ user.save! }.not_to raise_error }
      end

      context 'and has validation errors' do
        let(:user){ User.create(name: 'Undr') }

        before{ user.name = nil }

        specify{ expect{ user.save! }.to raise_error(Rubberry::DocumentInvalid) }
      end
    end
  end
end
