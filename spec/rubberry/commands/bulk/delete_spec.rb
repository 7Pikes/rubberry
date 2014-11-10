require 'spec_helper'

describe Rubberry::Commands::Bulk::Delete do
  before do
    stub_model('User') do
      mappings do
        field :name
      end
    end
    User.index.create
  end

  after{ User.index.delete }

  let(:user){ User.create(name: 'Undr') }
  let(:options){ {} }

  describe '#request' do
    subject{ Rubberry::Commands::Bulk::Delete.new(user, options).request }

    specify{ expect(subject).to eq('delete' => { _index: 'test_users', _type: 'user', _id: user._id }) }

    context 'with invalid option' do
      let(:options){ { lalala: 'lalala' } }
      specify{ expect{ subject }.to raise_error(Optionable::Unknown) }
    end
  end

  describe '#perform' do
    let(:bulk){ [] }
    let!(:command){ Rubberry::Commands::Bulk::Delete.new(user, options) }

    before{ allow(Rubberry).to receive(:bulk).and_return([]) }

    context 'when document is destroyable' do
      specify{ expect(command.perform).to be_truthy }

      context do
        before{ command.perform }
        specify{ expect(Rubberry.bulk).to eq([command]) }
        specify{ expect(user).not_to be_destroyed }
        specify{ expect(user).to be_bulked }
      end
    end

    context 'when document is not destroyable' do
      before{ allow(user).to receive(:destroyable?).and_return(false) }

      specify{ expect(command.perform).to be_falsy }

      context do
        before{ command.perform }
        specify{ expect(Rubberry.bulk).to eq([]) }
        specify{ expect(user).not_to be_destroyed }
        specify{ expect(user).not_to be_bulked }
      end
    end
  end
end
