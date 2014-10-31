require 'spec_helper'

describe Rubberry::Context do
  before do
    stub_model('User') do
      mappings do
        field :name
        field :counter, type: 'integer', default: 0
      end
    end
    User.index.create
  end

  after{ User.index.delete }

  describe '.create' do
    let!(:user){ User.create(name: 'Undr') }

    subject{ user }

    specify{ expect(subject).not_to be_new_record }
    specify{ expect(subject).to be_persisted }
    specify{ expect(subject).not_to be_changed }
    specify{ expect(subject._id).not_to be_nil }
    specify{ expect(subject._version).to eq(1) }
    specify{ expect(subject.name).to eq('Undr') }

    context 'stored object' do
      subject{ User.find(user._id) }

      specify{ expect(subject).not_to be_new_record }
      specify{ expect(subject).to be_persisted }
      specify{ expect(subject).not_to be_changed }
      specify{ expect(subject._id).not_to be_nil }
      specify{ expect(subject._version).to eq(1) }
      specify{ expect(subject.name).to eq('Undr') }
    end
  end

  describe '.increment' do
    let!(:user){ User.create(name: 'Undr') }

    specify{ expect{ User.increment('qwerty', :counter) }.to raise_error(Rubberry::DocumentNotFound) }

    context do
      before{ User.increment(user._id, :unexisted_counter) }

      subject{ User.find(user._id) }

      specify{ expect{ subject.unexisted_counter }.to raise_error(NoMethodError) }
      specify{ expect(subject._version).to eq(2) }
    end

    context do
      before{ User.increment(user._id, :counter) }

      subject{ User.find(user._id) }

      specify{ expect(subject.counter).to eq(1) }
      specify{ expect(subject._version).to eq(2) }
    end

    context do
      before{ User.increment(user._id, counter: 2.5) }

      subject{ User.find(user._id) }

      specify{ expect(subject.counter).to eq(2) }
      specify{ expect(subject._version).to eq(2) }
    end

    context do
      before{ User.increment(user._id, counter: 10) }

      subject{ User.find(user._id) }

      specify{ expect(subject.counter).to eq(10) }
      specify{ expect(subject._version).to eq(2) }
    end

    context do
      before{ User.increment(user._id, counter: -10) }

      subject{ User.find(user._id) }

      specify{ expect(subject.counter).to eq(-10) }
      specify{ expect(subject._version).to eq(2) }
    end
  end

  describe '.decrement' do
    let!(:user){ User.create(name: 'Undr') }

    specify{ expect{ User.decrement('qwerty', :counter) }.to raise_error(Rubberry::DocumentNotFound) }

    context do
      before{ User.decrement(user._id, :unexisted_counter) }

      subject{ User.find(user._id) }

      specify{ expect{ subject.unexisted_counter }.to raise_error(NoMethodError) }
      specify{ expect(subject._version).to eq(2) }
    end

    context do
      before{ User.decrement(user._id, :counter) }

      subject{ User.find(user._id) }

      specify{ expect(subject.counter).to eq(-1) }
      specify{ expect(subject._version).to eq(2) }
    end

    context do
      before{ User.decrement(user._id, counter: 2.5) }

      subject{ User.find(user._id) }

      specify{ expect(subject.counter).to eq(-2) }
      specify{ expect(subject._version).to eq(2) }
    end

    context do
      before{ User.decrement(user._id, counter: 10) }

      subject{ User.find(user._id) }

      specify{ expect(subject.counter).to eq(-10) }
      specify{ expect(subject._version).to eq(2) }
    end

    context do
      before{ User.decrement(user._id, counter: -10) }

      subject{ User.find(user._id) }

      specify{ expect(subject.counter).to eq(10) }
      specify{ expect(subject._version).to eq(2) }
    end
  end

  describe '.instantiate' do
    let(:doc){ {
      '_index' => 'blogs',
      '_type' => 'blog',
      '_id' => 'OhYF6lIaRxuQLoDsIE2z',
      '_version' => 2,
      '_score' => 1.0,
      '_source' => { 'name' => 'Some name' },
      'highlight' => { 'name' => ['Some <em>name</em>'] }
    } }

    subject{ User.instantiate(doc) }

    specify{ expect(subject).to be_persisted }
    specify{ expect(subject).not_to be_changed }
    specify{ expect(subject).to be_instance_of(User) }
    specify{ expect(subject.name).to eq('Some name') }
    specify{ expect(subject.highlighted_name).to eq(['Some <em>name</em>']) }
    specify{ expect(subject._id).to eq('OhYF6lIaRxuQLoDsIE2z') }
    specify{ expect(subject._version).to eq(2) }
  end

  describe '#init_with' do
    let(:doc){ {
      '_index' => 'blogs',
      '_type' => 'blog',
      '_id' => 'OhYF6lIaRxuQLoDsIE2z',
      '_version' => 2,
      '_score' => 1.0,
      '_source' => { 'name' => 'Some name' },
      'highlight' => { 'name' => ['Some <em>name</em>'] }
    } }

    subject{ User.new.init_with(doc) }

    specify{ expect(subject).to be_persisted }
    specify{ expect(subject).not_to be_changed }
    specify{ expect(subject).to be_instance_of(User) }
    specify{ expect(subject.name).to eq('Some name') }
    specify{ expect(subject.highlighted_name).to eq(['Some <em>name</em>']) }
    specify{ expect(subject._id).to eq('OhYF6lIaRxuQLoDsIE2z') }
    specify{ expect(subject._version).to eq(2) }
  end

  describe '#save' do
    context 'when it is new record' do
      let(:user){ User.new(name: 'Undr') }

      before{ user.save }

      specify{ expect(user).not_to be_new_record }
      specify{ expect(user).to be_persisted }
      specify{ expect(user).not_to be_changed }
      specify{ expect(user._id).not_to be_nil }
      specify{ expect(user._version).to eq(1) }
      specify{ expect(user.name).to eq('Undr') }

      context 'stored object' do
        subject{ User.find(user._id) }

        specify{ expect(subject).not_to be_new_record }
        specify{ expect(subject).to be_persisted }
        specify{ expect(subject).not_to be_changed }
        specify{ expect(subject._id).not_to be_nil }
        specify{ expect(subject._version).to eq(1) }
        specify{ expect(subject.name).to eq('Undr') }
      end
    end

    context 'when it is not new record' do
      let(:user){ User.create(name: 'Undr') }

      before do
        user.name = 'Arny'
        user.save
      end

      specify{ expect(user).not_to be_new_record }
      specify{ expect(user).to be_persisted }
      specify{ expect(user).not_to be_changed }
      specify{ expect(user._id).not_to be_nil }
      specify{ expect(user._version).to eq(2) }
      specify{ expect(user.name).to eq('Arny') }

      context 'stored object' do
        subject{ User.find(user._id) }

        specify{ expect(subject).not_to be_new_record }
        specify{ expect(subject).to be_persisted }
        specify{ expect(subject).not_to be_changed }
        specify{ expect(subject._id).not_to be_nil }
        specify{ expect(subject._version).to eq(2) }
        specify{ expect(subject.name).to eq('Arny') }
      end
    end

    context 'when document is readonly' do
      let(:user){ User.create(name: 'Undr') }

      before do
        user.name = 'Arny'
        user.readonly!
      end

      specify{ expect(user.save).to be_falsy }
      specify{ expect(user.reload.name).to eq('Undr') }
    end
  end

  describe '#save!' do
    context 'when it is new record' do
      let(:user){ User.new(name: 'Undr') }

      before{ user.save! }

      specify{ expect(user).not_to be_new_record }
      specify{ expect(user).to be_persisted }
      specify{ expect(user).not_to be_changed }
      specify{ expect(user._id).not_to be_nil }
      specify{ expect(user._version).to eq(1) }
      specify{ expect(user.name).to eq('Undr') }

      context 'stored object' do
        subject{ User.find(user._id) }

        specify{ expect(subject).not_to be_new_record }
        specify{ expect(subject).to be_persisted }
        specify{ expect(subject).not_to be_changed }
        specify{ expect(subject._id).not_to be_nil }
        specify{ expect(subject._version).to eq(1) }
        specify{ expect(subject.name).to eq('Undr') }
      end
    end

    context 'when it is not new record' do
      let(:user){ User.create(name: 'Undr') }

      before do
        user.name = 'Arny'
        user.save!
      end

      specify{ expect(user).not_to be_new_record }
      specify{ expect(user).to be_persisted }
      specify{ expect(user).not_to be_changed }
      specify{ expect(user._id).not_to be_nil }
      specify{ expect(user._version).to eq(2) }
      specify{ expect(user.name).to eq('Arny') }

      context 'stored object' do
        subject{ User.find(user._id) }

        specify{ expect(subject).not_to be_new_record }
        specify{ expect(subject).to be_persisted }
        specify{ expect(subject).not_to be_changed }
        specify{ expect(subject._id).not_to be_nil }
        specify{ expect(subject._version).to eq(2) }
        specify{ expect(subject.name).to eq('Arny') }
      end
    end

    context 'when document is readonly' do
      let(:user){ User.create(name: 'Undr') }

      before do
        user.name = 'Arny'
        user.readonly!
      end

      specify{ expect{ user.save! }.to raise_error(Rubberry::ReadOnlyDocument) }
    end
  end

  describe '#delete' do
    let(:user){ User.create(name: 'Undr') }

    subject{ user }

    before{ user.delete }

    specify{ expect(subject).not_to be_persisted }
    specify{ expect(subject).to be_destroyed }

    context do
      subject{ User.find(user._id) }
      specify{ expect(subject).to be_nil }
    end
  end

  describe '#increment' do
    let(:user){ User.create(name: 'Undr') }

    specify{ expect{ user.increment(:counter) }.to change{ user.counter }.from(0).to(1) }
    specify{ expect{ user.increment(:counter) }.to change{ User.find(user._id).counter }.from(0).to(1) }
    specify{ expect{ user.increment(counter: 10) }.to change{ user.counter }.from(0).to(10) }
    specify{ expect{ user.increment(counter: 10) }.to change{ User.find(user._id).counter }.from(0).to(10) }

    context 'with atomic option and dynamic_scripting disabled' do
      context do
        before{ expect(User).not_to receive(:increment) }
        specify{ expect{ user.increment(:counter, atomic: true) }.to change{ user.counter }.from(0).to(1) }
        specify{ expect{ user.increment(:counter, atomic: true) }.to change{
          User.find(user._id).counter
        }.from(0).to(1) }
      end

      context do
        before{ expect(User).not_to receive(:increment) }
        specify{ expect{ user.increment({ counter: 10 }, atomic: true) }.to change{ user.counter }.from(0).to(10) }
        specify{ expect{ user.increment({ counter: 10 }, atomic: true) }.to change{
          User.find(user._id).counter
        }.from(0).to(10) }
      end
    end

    context 'with atomic option and dynamic_scripting enabled' do
      before{ User.config.dynamic_scripting = true }
      after{ User.config.dynamic_scripting = false }

      context do
        before{ expect(User).to receive(:increment).with(user._id, :counter).and_call_original }
        specify{ expect{ user.increment(:counter, atomic: true) }.to change{ user.counter }.from(0).to(1) }
        specify{ expect{ user.increment(:counter, atomic: true) }.to change{
          User.find(user._id).counter
        }.from(0).to(1) }
      end

      context do
        before{ expect(User).to receive(:increment).with(user._id, counter: 10).and_call_original }
        specify{ expect{ user.increment({ counter: 10 }, atomic: true) }.to change{ user.counter }.from(0).to(10) }
        specify{ expect{ user.increment({ counter: 10 }, atomic: true) }.to change{
          User.find(user._id).counter
        }.from(0).to(10) }
      end
    end
  end

  describe '#decrement' do
    let(:user){ User.create(name: 'Undr') }

    specify{ expect{ user.decrement(:counter) }.to change{ user.counter }.from(0).to(-1) }
    specify{ expect{ user.decrement(:counter) }.to change{ User.find(user._id).counter }.from(0).to(-1) }
    specify{ expect{ user.decrement(counter: 10) }.to change{ user.counter }.from(0).to(-10) }
    specify{ expect{ user.decrement(counter: 10) }.to change{ User.find(user._id).counter }.from(0).to(-10) }

    context 'with atomic option and dynamic_scripting disabled' do
      context do
        before{ expect(User).not_to receive(:decrement) }
        specify{ expect{ user.decrement(:counter, atomic: true) }.to change{ user.counter }.from(0).to(-1) }
        specify{ expect{ user.decrement(:counter, atomic: true) }.to change{
          User.find(user._id).counter
        }.from(0).to(-1) }
      end

      context do
        before{ expect(User).not_to receive(:decrement) }
        specify{ expect{ user.decrement({ counter: 10 }, atomic: true) }.to change{ user.counter }.from(0).to(-10) }
        specify{ expect{ user.decrement({ counter: 10 }, atomic: true) }.to change{
          User.find(user._id).counter
        }.from(0).to(-10) }
      end
    end

    context 'with atomic option and dynamic_scripting enabled' do
      before{ User.config.dynamic_scripting = true }
      after{ User.config.dynamic_scripting = false }

      context do
        before{ expect(User).to receive(:decrement).with(user._id, :counter).and_call_original }
        specify{ expect{ user.decrement(:counter, atomic: true) }.to change{ user.counter }.from(0).to(-1) }
        specify{ expect{ user.decrement(:counter, atomic: true) }.to change{
          User.find(user._id).counter
        }.from(0).to(-1) }
      end

      context do
        before{ expect(User).to receive(:decrement).with(user._id, counter: 10).and_call_original }
        specify{ expect{ user.decrement({ counter: 10 }, atomic: true) }.to change{ user.counter }.from(0).to(-10) }
        specify{ expect{ user.decrement({ counter: 10 }, atomic: true) }.to change{
          User.find(user._id).counter
        }.from(0).to(-10) }
      end
    end
  end

  describe '#update_attribute' do
    let(:user){ User.create(name: 'Undr') }

    specify{ expect{ user.update_attribute(:name, 'Arny') }.to change{ user.name }.from('Undr').to('Arny') }
    specify{ expect{ user.update_attribute(:name, 'Arny') }.to change{ user.reload.name }.from('Undr').to('Arny') }
  end

  describe '#update_attributes' do
    let(:user){ User.create(name: 'Undr') }

    specify{ expect{
      user.update_attributes(name: 'Arny', counter: 10)
    }.to change{ user.name }.from('Undr').to('Arny') }

    specify{ expect{
      user.update_attributes(name: 'Arny', counter: 10)
    }.to change{ user.counter }.from(0).to(10) }

    specify{ expect{
      user.update_attributes(name: 'Arny', counter: 10)
    }.to change{ user.reload.name }.from('Undr').to('Arny') }

    specify{ expect{
      user.update_attributes(name: 'Arny', counter: 10)
    }.to change{ user.reload.counter }.from(0).to(10) }
  end

  describe '#reload' do
    let(:user){ User.create(name: 'Undr') }

    context do
      subject do
        User.increment(user._id, :counter)
        user.reload
      end

      specify{ expect(subject).to be_persisted }
      specify{ expect(subject).not_to be_changed }
      specify{ expect(subject.counter).to eq(1) }
    end

    context 'for deleted object' do
      before{ user.delete }
      specify{ expect{ user.reload }.to raise_error(Rubberry::DocumentNotFound) }
    end
  end
end
