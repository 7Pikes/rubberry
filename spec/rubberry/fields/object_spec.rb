require 'spec_helper'

describe Rubberry::Fields::Object do
  subject do
    build_field(:comment, type: 'object').tap do |f|
      f.add(build_field(:title, type: 'string'))
      f.add(build_field(:created_at, type: 'date'))

      author = build_field(:author, type: 'object').tap do |ff|
        ff.add(build_field(:name))
      end
      f.add(author)
    end
  end

  describe '#type_cast', time_freeze: '2014-10-29T15:30:05.123+07:00' do
    specify{ expect(subject.type_cast(nil)).to be_nil }
    specify{ expect(subject.type_cast({})).to eq(OpenStruct.new(title: nil, created_at: nil, author: nil)) }
    specify{ expect(subject.type_cast(
      'title' => 'Title', 'some_key' => 'Value'
    )).to eq(OpenStruct.new(title: 'Title', created_at: nil, author: nil)) }

    specify{ expect(subject.type_cast(
      'title' => 'Title', 'last' => 'Great', 'created_at' => Time.now, 'author' => { name: 'Undr' }
    )).to eq(OpenStruct.new(title: 'Title', created_at: Time.now.to_datetime, author: OpenStruct.new(name: 'Undr'))) }
  end

  describe '#elasticize', time_freeze: '2014-10-29T15:30:05.123+07:00' do
    specify{ expect(subject.type_cast(nil).elasticize).to be_nil }
    specify{ expect(subject.type_cast({}).elasticize).to eq('title' => nil, 'created_at' => nil, 'author' => nil) }
    specify{ expect(subject.type_cast(
      'title' => 'Title', 'some_key' => 'Value'
    ).elasticize).to eq('title' => 'Title', 'created_at' => nil, 'author' => nil) }

    specify{ expect(subject.type_cast(
      'title' => 'Title', 'last' => 'Great', 'created_at' => Time.now, 'author' => { name: 'Undr' }
    ).elasticize).to eq(
      'title' => 'Title', 'created_at' => '2014-10-29T08:30:05.123', 'author' => { 'name' => 'Undr' }
    ) }
  end
end
