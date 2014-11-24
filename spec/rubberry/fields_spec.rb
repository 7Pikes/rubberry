require 'spec_helper'

describe Rubberry::Fields do
  let(:model){ Model }

  subject{ model }

  describe '.fields' do
    specify{ expect(subject.fields.keys).to eq(['string', 'string_with_default', 'integer', 'multi_field', 'object']) }
    specify do
      subject.fields.each do |_, field|
        expect(field).to be_kind_of(Rubberry::Fields::Base)
      end
    end
  end

  describe '.has_field?' do
    specify{ expect(model.has_field?(:string)).to be_truthy }
    specify{ expect(model.has_field?('string')).to be_truthy }
    specify{ expect(model.has_field?(:string_with_default)).to be_truthy }
    specify{ expect(model.has_field?('string_with_default')).to be_truthy }
    specify{ expect(model.has_field?(:integer)).to be_truthy }
    specify{ expect(model.has_field?('integer')).to be_truthy }
    specify{ expect(model.has_field?(:multi_field)).to be_truthy }
    specify{ expect(model.has_field?('multi_field')).to be_truthy }
    specify{ expect(model.has_field?(:object)).to be_truthy }
    specify{ expect(model.has_field?('object')).to be_truthy }

    specify{ expect(model.has_field?(:raw)).to be_falsy }
    specify{ expect(model.has_field?('raw')).to be_falsy }
    specify{ expect(model.has_field?(:subfield)).to be_falsy }
    specify{ expect(model.has_field?('subfield')).to be_falsy }
  end

  describe '.initialize_attributes' do
    specify{ expect(model.initialize_attributes).to eq(
      'string' => nil,
      'string_with_default' => nil,
      'integer' => nil,
      'multi_field' => nil,
      'object' => nil
    ) }
    specify{ expect(model.initialize_attributes.keys).to eq(subject.fields.keys) }
  end

  describe '.inherited' do
    let(:submodel){ SubModel }

    specify{ expect(model._mappings.equal?(submodel._mappings)).to be_falsy }
    specify{ expect(model._mappings.fields).to eq(submodel._mappings.fields) }
  end

  describe '.mappings' do
    before{ expect(model._mappings).to receive(:instance_exec).and_yield }
    specify{ expect{|b| model.mappings(&b) }.to yield_with_no_args }
  end

  describe '#initialize' do
    context 'without argument' do
      subject{ model.new }

      specify{ expect(subject.attributes).to eq(
        'string' => nil,
        'string_with_default' => 'default string',
        'integer' => nil,
        'multi_field' => nil,
        'object' => nil
      ) }
    end

    context 'with argument' do
      subject{ model.new(
        string: 'some string', string_with_default: 'another string', object: { subfield: 'string' }
      ) }

      specify{ expect(subject.attributes).to eq(
        'string' => 'some string',
        'string_with_default' => 'another string',
        'integer' => nil,
        'multi_field' => nil,
        'object' => OpenStruct.new(subfield: 'string')
      ) }
    end
  end

  describe '#write_attribute' do
    subject{ model.new }

    specify{ expect{ subject.write_attribute('string', 'value') }.to change{ subject.string }.from(nil).to('value') }
    specify{ expect{ subject['string'] ='value' }.to change{ subject.string }.from(nil).to('value') }
    specify{ expect{ subject[:string] ='value' }.to change{ subject.string }.from(nil).to('value') }
    specify{ expect{ subject.string = 'value' }.to change{ subject.string }.from(nil).to('value') }
  end

  describe '#read_attribute' do
    subject{ model.new }

    specify{ expect(subject.read_attribute('string')).to be_nil }
    specify{ expect(subject.string).to be_nil }
    specify{ expect(subject['string']).to be_nil }
    specify{ expect(subject[:string]).to be_nil }

    context 'with value' do
      subject{ model.new(string: 'value') }
      specify{ expect(subject.read_attribute('string')).to eq('value') }
      specify{ expect(subject.string).to eq('value') }
      specify{ expect(subject['string']).to eq('value') }
      specify{ expect(subject[:string]).to eq('value') }
    end

    context 'with default value' do
      subject{ model.new }
      specify{ expect(subject.read_attribute('string_with_default')).to eq('default string') }
      specify{ expect(subject.string_with_default).to eq('default string') }
      specify{ expect(subject['string_with_default']).to eq('default string') }
      specify{ expect(subject[:string_with_default]).to eq('default string') }
    end
  end

  describe '#read_highlighted_attribute' do
    subject{ model.new.init_with('highlight' => { 'string' => '<b>string</b>' }, '_source' => {}) }
    specify{ expect(subject.highlighted_string).to eq('<b>string</b>') }
    specify{ expect(subject.read_highlighted_attribute('string')).to eq('<b>string</b>') }
    specify{ expect(subject.highlighted_integer).to be_nil }
    specify{ expect(subject.read_highlighted_attribute('integer')).to be_nil }
  end

  describe '#elasticated_attributes' do
    subject{ model.new(
      string: 'some string',
      string_with_default: 'another string',
      integer: 10,
      multi_field: 'value',
      object: { subfield: 'string' }
    ) }

    specify{ expect(subject.elasticated_attributes).to eq(
      'string' => 'some string',
      'string_with_default' => 'another string',
      'integer' => 10,
      'multi_field' => 'value',
      'object' => { 'subfield' => 'string' }
    ) }

    context 'when persisted' do
      before do
        allow(subject).to receive(:_id).and_return('qwerty')
        allow(subject).to receive(:persisted?).and_return(true)
      end

      specify{ expect(subject.elasticated_attributes).to eq(
        '_id' => 'qwerty',
        'string' => 'some string',
        'string_with_default' => 'another string',
        'integer' => 10,
        'multi_field' => 'value',
        'object' => { 'subfield' => 'string' }
      ) }
    end
  end

  describe '#attributes' do
    subject{ model.new(
      string: 'some string',
      string_with_default: 'another string',
      integer: 10,
      multi_field: 'value',
      object: { subfield: 'string' }
    ) }

    specify{ expect(subject.attributes).to eq(
      'string' => 'some string',
      'string_with_default' => 'another string',
      'integer' => 10,
      'multi_field' => 'value',
      'object' => OpenStruct.new(subfield: 'string')
    ) }

    context 'when persisted' do
      before do
        allow(subject).to receive(:_id).and_return('qwerty')
        allow(subject).to receive(:persisted?).and_return(true)
      end

      specify{ expect(subject.attributes).to eq(
        '_id' => 'qwerty',
        'string' => 'some string',
        'string_with_default' => 'another string',
        'integer' => 10,
        'multi_field' => 'value',
        'object' => OpenStruct.new(subfield: 'string')
      ) }
    end
  end

  describe '#attribute_names' do
    subject{ model.new }
    specify{ expect(subject.attribute_names).to eq(model.fields.keys) }
  end
end
