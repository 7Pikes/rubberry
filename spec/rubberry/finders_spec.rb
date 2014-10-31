require 'spec_helper'

describe Rubberry::Finders do
  before do
    stub_model('User') do
      mappings do
        field :name
      end
    end
    User.index.create
  end

  after{ User.index.delete }

  let(:user1){ User.create!(name: 'Undr') }
  let(:user2){ User.create!(name: 'Arny') }
  let(:user3){ User.create!(name: 'Rob') }

  before seed: true do
    user1; user2; user3
  end

  describe '#find', seed: true do
    context 'when id is blank' do
      specify{ expect(User.find(nil)).to be_nil }
      specify{ expect(User.find('')).to be_nil }
    end

    context 'with valid id' do
      specify{ expect(User.find(user2._id)).to eq(user2) }
      specify{ expect(User.find([user2._id, user1._id])).to eq([user2, user1]) }
    end

    context 'with invalid id' do
      specify{ expect(User.find('qwerty')).to be_nil }
      specify{ expect(User.find(['qwerty', 'asdfgh'])).to eq([nil, nil]) }
    end
  end

  describe '#find!', seed: true do
    context 'when id is blank' do
      specify{ expect{ User.find!(nil) }.to raise_error(Rubberry::DocumentNotFound, "Couldn't find User without an ID") }
      specify{ expect{ User.find!('') }.to raise_error(Rubberry::DocumentNotFound, "Couldn't find User without an ID") }
    end

    context 'with valid id' do
      specify{ expect(User.find!(user2._id)).to eq(user2) }
      specify{ expect(User.find!([user2._id, user1._id])).to eq([user2, user1]) }
    end

    context 'with invalid id' do
      specify{ expect{ User.find!('qwerty') }.to raise_error(Rubberry::DocumentNotFound, /qwerty/) }
      specify{ expect{ User.find!(['qwerty', 'asdfgh']) }.to raise_error(Rubberry::DocumentNotFound, /qwerty, asdfgh/) }
      specify{ expect{ User.find!([user2._id, 'asdfgh']) }.to raise_error(Rubberry::DocumentNotFound, /asdfgh/) }
    end
  end

  describe '#exists?', seed: true do
    specify{ expect(User.exists?(user2._id)).to be_truthy }
    specify{ expect(User.exists?('qwerty')).to be_falsy }
  end

  Rubberry::Finders::CONTEXT_METHODS.each do |method_name|
    describe method_name do
      let(:context){ spy('context') }
      let(:method_name){ method_name }

      it 'delegates method to search context' do
        allow(User).to receive(:all).and_return(context)
        User.send(method_name)
        expect(context).to have_received(method_name)
      end
    end
  end
end
