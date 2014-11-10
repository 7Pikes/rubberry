require 'spec_helper'

describe Rubberry::Commands do
  before do
    stub_model('User') do
      mappings do
        field :name
      end
    end
    User.index.create
  end

  after{ User.index.delete }

  let(:doc){ User.new }

  describe '.build' do
    context do
      subject{ Rubberry::Commands.build('Create', doc) }
      specify{ expect(subject).to be_instance_of(Rubberry::Commands::Create) }
    end

    context 'with namespaced type' do
      subject{ Rubberry::Commands.build('Atomic::Increment', User, counters: :counter, id: doc._id) }
      specify{ expect(subject).to be_instance_of(Rubberry::Commands::Atomic::Increment) }
    end

    context 'bulk command' do
      before{ allow(Rubberry).to receive(:bulk?).and_return(true) }

      subject{ Rubberry::Commands.build('Create', doc) }

      specify{ expect(subject).to be_instance_of(Rubberry::Commands::Bulk::Create) }
    end

    context 'non bulk context' do
      before{ allow(Rubberry).to receive(:bulk?).and_return(true) }

      subject{ Rubberry::Commands.build('DeleteAll', User.context) }

      specify{ expect(subject).to be_instance_of(Rubberry::Commands::DeleteAll) }
    end
  end
end
