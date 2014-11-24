require 'spec_helper'

describe Rubberry::Validations, index_model: Admin do
  describe '.create!' do
    context 'create with validation errors' do
      specify{ expect{ Admin.create!(counter: 2) }.to raise_error(Rubberry::DocumentInvalid) }
    end

    context 'create without validation errors' do
      subject{ Admin.create!(name: 'Undr') }

      specify{ expect(subject).to be_persisted }
      specify{ expect(subject).to be_instance_of(Admin) }
    end
  end

  describe '#save' do
    context 'when it is new record' do
      context 'and no validation errors' do
        let(:user){ Admin.new(name: 'Undr') }

        before{ user.save }

        specify{ expect(user).to be_persisted }
      end

      context 'and has validation errors' do
        let(:user){ Admin.new(counter: 2) }

        specify{ expect(user.save).to be_falsy }
        specify{ expect{ user.save }.to change{ user.errors } }
      end
    end

    context 'when it is not new record' do
      context 'and no validation errors' do
        let(:user){ Admin.create(name: 'Undr') }

        before do
          user.name = 'Arny'
          user.save
        end

        specify{ expect(user).to be_persisted }
      end

      context 'and has validation errors' do
        let(:user){ Admin.create(name: 'Undr') }

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
        let(:user){ Admin.new(name: 'Undr') }

        specify{ expect{ user.save! }.not_to raise_error }
      end

      context 'and has validation errors' do
        let(:user){ Admin.new(counter: 2) }

        specify{ expect{ user.save! }.to raise_error(Rubberry::DocumentInvalid) }
      end
    end

    context 'when it is not new record' do
      context 'and no validation errors' do
        let(:user){ Admin.create(name: 'Undr') }

        before{ user.name = 'Arny' }

        specify{ expect{ user.save! }.not_to raise_error }
      end

      context 'and has validation errors' do
        let(:user){ Admin.create(name: 'Undr') }

        before{ user.name = nil }

        specify{ expect{ user.save! }.to raise_error(Rubberry::DocumentInvalid) }
      end
    end
  end
end
