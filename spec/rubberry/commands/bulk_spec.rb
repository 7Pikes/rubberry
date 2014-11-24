require 'spec_helper'

describe Rubberry::Commands::Bulk, index_model: SomeUser do
  let!(:user1){ SomeUser.new(name: 'Undr') }
  let!(:user2){ SomeUser.create(name: 'Ammy').tap{|u| u.assign_attributes(name: 'Amy', counter: 10) } }
  let!(:user3){ SomeUser.create(name: 'Rob') }
  let!(:user4){ SomeUser.create(name: 'Ron') }

  describe '#request' do
    let(:options){ {} }

    before{ Rubberry::Commands::Bulk.send(:public, :stack) }

    subject do
      Rubberry::Commands::Bulk.new.tap do |bulk|
        bulk.stack.push(Rubberry::Commands::Bulk::Bunch.new(options))
        bulk.add(Rubberry::Commands::Bulk::Create.new(user1))
        bulk.add(Rubberry::Commands::Bulk::Update.new(user2))
        bulk.add(Rubberry::Commands::Bulk::Delete.new(user3))
        bulk.add(Rubberry::Commands::Bulk::Increment.new(user4, counters: :counter))
      end
    end

    specify{ expect(subject.request).to eq(refresh: true, body: [
      { 'create' => {
        _index: 'test_some_users', _type: 'user', data: { 'name' => 'Undr', 'handsome' => true, 'counter' => 0 }
      } },
      { 'update' => {
        _index: 'test_some_users', _type: 'user', _id: user2._id, data: { doc: { 'name' => 'Amy', 'counter' => 10 } }
      } },
      { 'delete' => { _index: 'test_some_users', _type: 'user', _id: user3._id } },
      { 'update' => {
        _index: 'test_some_users',
        _type: 'user',
        _id: user4._id,
        data: { script: 'if(isdef ctx._source.counter){ ctx._source.counter += 1 } else { ctx._source.counter = 1 }' }
      } }
    ]) }

    context 'with options' do
      let(:options){ { refresh: false, consistency: :one, replication: :sync, timeout: '10s' } }

      specify{ expect(subject.request).to eq(
        refresh: false,
        consistency: :one,
        replication: :sync,
        timeout: '10s',
        body: [
          { 'create' => {
            _index: 'test_some_users', _type: 'user', data: { 'name' => 'Undr', 'handsome' => true, 'counter' => 0 }
          } },
          { 'update' => {
            _index: 'test_some_users', _type: 'user', _id: user2._id, data: { doc: { 'name' => 'Amy', 'counter' => 10 } }
          } },
          { 'delete' => { _index: 'test_some_users', _type: 'user', _id: user3._id } },
          { 'update' => {
            _index: 'test_some_users',
            _type: 'user',
            _id: user4._id,
            data: {
              script: 'if(isdef ctx._source.counter){ ctx._source.counter += 1 } else { ctx._source.counter = 1 }'
            }
          } }
        ]
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
    let(:options){ {} }

    subject do
      Rubberry::Commands::Bulk.instance.perform(options) do
        Rubberry::Commands::Bulk::Create.new(user1).perform
        Rubberry::Commands::Bulk::Update.new(user2).perform
        Rubberry::Commands::Bulk::Delete.new(user3).perform
        Rubberry::Commands::Bulk::Increment.new(user4, counters: :counter).perform
      end
    end

    specify{ expect(subject).to eq([user1, user2, user3, user4]) }

    context do
      before{ subject }

      specify{ expect(user1).to be_persisted }
      specify{ expect(user1.name).to eq('Undr') }
      specify{ expect(user1.changed?).to be_falsy }
      specify{ expect(user1.bulked?).to be_falsy }
      specify{ expect(user1._id).not_to be_nil }
      specify{ expect(user1._version).not_to be_nil }
      specify{ expect(SomeUser.find(user1._id)).not_to be_nil }

      specify{ expect(user2.name).to eq('Amy') }
      specify{ expect(user2.changed?).to be_falsy }
      specify{ expect(user2.bulked?).to be_falsy }
      specify{ expect(user2.reload.name).to eq('Amy') }

      specify{ expect(user3).to be_destroyed }
      specify{ expect(user1.bulked?).to be_falsy }
      specify{ expect(SomeUser.find(user3._id)).to be_nil }

      specify{ expect(user4).to be_persisted }
      specify{ expect(user1.bulked?).to be_falsy }
      specify{ expect(user4.counter).to eq(1) }
      specify{ expect(user4.reload.counter).to eq(1) }
    end
  end
end
