require 'spec_helper'

describe Rubberry::Fields::Base do
  let(:options){ { key: 'value' } }
  let(:default){ subject.instance_variable_get(:@default) }

  subject{ Rubberry::Fields::Base.new(:name, options) }

  describe '#initialize' do
    specify{ expect(subject.name).to eq('name') }
    specify{ expect(subject).not_to be_as_array }
    specify{ expect(subject).not_to be_nested }
    specify{ expect(subject.options).to eq(options) }
    specify{ expect(subject.children).to eq([]) }
    specify{ expect(default).to be_nil }

    context 'as array' do
      let(:options){ { array: true, key: 'value' } }

      specify{ expect(subject.name).to eq('name') }
      specify{ expect(subject).to be_as_array }
      specify{ expect(subject).not_to be_nested }
      specify{ expect(subject.options).to eq(key: 'value') }
      specify{ expect(subject.children).to eq([]) }
      specify{ expect(default).to be_nil }
    end

    context 'with default value' do
      let(:options){ { default: 'default', key: 'value' } }

      specify{ expect(subject.name).to eq('name') }
      specify{ expect(subject).not_to be_as_array }
      specify{ expect(subject).not_to be_nested }
      specify{ expect(subject.options).to eq(key: 'value') }
      specify{ expect(subject.children).to eq([]) }
      specify{ expect(default).to eq('default') }
    end
  end

  describe '#default_value' do
    let(:object){ double(:object, default: 'default') }

    subject{ Rubberry::Fields::Base.new(:name, options).default_value(object) }

    specify{ expect(subject).to be_nil }

    context 'with :default option' do
      let(:options){ { default: 'default' } }
      specify{ expect(subject).to eq('default') }
    end

    context 'with :default option as block with ariry == 0' do
      let(:options){ { default: ->{ default } } }
      specify{ expect(subject).to eq('default') }
    end

    context 'with :default option as block with ariry > 0' do
      let(:options){ { default: ->(o){ o.default } } }
      specify{ expect(subject).to eq('default') }
    end
  end

  describe '#type_cast' do
    specify{ expect(subject.type_cast('value')).to eq('value') }
    specify{ expect(subject.type_cast('value')).to be_value_proxy }
    specify{ expect(subject.type_cast('value')).to respond_to(:elasticize) }
    specify{ expect(subject.type_cast('value') || 'o').to eq('value') }

    context 'with nil' do
      specify{ expect(subject.type_cast(nil)).to be_nil }
      specify{ expect(subject.type_cast(nil)).not_to be_value_proxy }
      specify{ expect(subject.type_cast(nil)).to respond_to(:elasticize) }
      specify{ expect(subject.type_cast(nil) || 'o').to eq('o') }
    end

    context 'with false' do
      specify{ expect(subject.type_cast(false)).to be_falsy }
      specify{ expect(subject.type_cast(false)).not_to be_value_proxy }
      specify{ expect(subject.type_cast(false)).to respond_to(:elasticize) }
      specify{ expect(subject.type_cast(false) || 'o').to eq('o') }
    end

    context 'with arrayed field' do
      let(:options){ { array: true } }

      specify{ expect(subject.type_cast('value')).to eq(['value']) }
      specify{ expect(subject.type_cast('value')).to be_value_proxy }
      specify{ expect(subject.type_cast('value')).to respond_to(:elasticize) }

      specify{ expect(subject.type_cast(['value'])).to eq(['value']) }
      specify{ expect(subject.type_cast(['value'])).to be_value_proxy }
      specify{ expect(subject.type_cast(['value'])).to respond_to(:elasticize) }

      context 'with nil' do
        specify{ expect(subject.type_cast(nil)).to be_nil }
        specify{ expect(subject.type_cast(nil)).not_to be_value_proxy }
        specify{ expect(subject.type_cast(nil)).to respond_to(:elasticize) }
        specify{ expect(subject.type_cast(nil) || 'o').to eq('o') }
      end

      context 'with false' do
        specify{ expect(subject.type_cast(false)).to eq([false]) }
        specify{ expect(subject.type_cast(false)).to be_value_proxy }
        specify{ expect(subject.type_cast(false)).to respond_to(:elasticize) }
        specify{ expect(subject.type_cast(false) || 'o').to eq([false]) }
      end
    end
  end

  describe '#read_value' do
    let(:object){ double(:object) }

    specify{ expect(subject.read_value('value', object)).to eq('value') }
    specify{ expect(subject.read_value('value', object)).to be_value_proxy }
    specify{ expect(subject.read_value('value', object)).to respond_to(:elasticize) }
    specify{ expect(subject.read_value('value', object) || 'o').to eq('value') }

    context 'with nil' do
      specify{ expect(subject.read_value(nil, object)).to be_nil }
      specify{ expect(subject.read_value(nil, object)).not_to be_value_proxy }
      specify{ expect(subject.read_value(nil, object)).to respond_to(:elasticize) }
      specify{ expect(subject.read_value(nil, object) || 'o').to eq('o') }

      context 'when default value exists' do
        let(:options){ { default: 'default' } }

        specify{ expect(subject.read_value(nil, object)).to eq('default') }
        specify{ expect(subject.read_value(nil, object)).to be_value_proxy }
        specify{ expect(subject.read_value(nil, object)).to respond_to(:elasticize) }
      end
    end

    context 'with false' do
      specify{ expect(subject.read_value(false, object)).to be_falsy }
      specify{ expect(subject.read_value(false, object)).not_to be_value_proxy }
      specify{ expect(subject.read_value(false, object)).to respond_to(:elasticize) }
      specify{ expect(subject.read_value(false, object) || 'o').to eq('o') }
    end

    context 'with arrayed field' do
      let(:options){ { array: true } }

      specify{ expect(subject.read_value('value', object)).to eq(['value']) }
      specify{ expect(subject.read_value('value', object)).to be_value_proxy }
      specify{ expect(subject.read_value('value', object)).to respond_to(:elasticize) }

      specify{ expect(subject.read_value(['value'], object)).to eq(['value']) }
      specify{ expect(subject.read_value(['value'], object)).to be_value_proxy }
      specify{ expect(subject.read_value(['value'], object)).to respond_to(:elasticize) }

      context 'with nil' do
        specify{ expect(subject.read_value(nil, object)).to be_nil }
        specify{ expect(subject.read_value(nil, object)).not_to be_value_proxy }
        specify{ expect(subject.read_value(nil, object)).to respond_to(:elasticize) }
        specify{ expect(subject.read_value(nil, object) || 'o').to eq('o') }

        context 'when default value exists' do
          let(:options){ { array: true, default: 'default' } }

          specify{ expect(subject.read_value(nil, object)).to eq(['default']) }
          specify{ expect(subject.read_value(nil, object)).to be_value_proxy }
          specify{ expect(subject.read_value(nil, object)).to respond_to(:elasticize) }
        end
      end

      context 'with false' do
        specify{ expect(subject.read_value(false, object)).to eq([false]) }
        specify{ expect(subject.read_value(false, object)).to be_value_proxy }
        specify{ expect(subject.read_value(false, object)).to respond_to(:elasticize) }
        specify{ expect(subject.read_value(false, object) || 'o').to eq([false]) }
      end
    end
  end

  describe '#read_value_before_type_cast' do
    let(:object){ double(:object) }

    specify{ expect(subject.read_value_before_type_cast('value', object)).to eq('value') }
    specify{ expect(subject.read_value_before_type_cast('value', object)).not_to be_value_proxy }
    specify{ expect(subject.read_value_before_type_cast('value', object)).not_to respond_to(:elasticize) }

    context 'with nil' do
      specify{ expect(subject.read_value_before_type_cast(nil, object)).to be_nil }
      specify{ expect(subject.read_value_before_type_cast(nil, object)).not_to be_value_proxy }
      specify{ expect(subject.read_value_before_type_cast(nil, object)).to respond_to(:elasticize) }

      context 'when default value exists' do
        let(:options){ { default: 'default' } }

        specify{ expect(subject.read_value_before_type_cast(nil, object)).to eq('default') }
        specify{ expect(subject.read_value_before_type_cast(nil, object)).not_to be_value_proxy }
        specify{ expect(subject.read_value_before_type_cast(nil, object)).not_to respond_to(:elasticize) }
      end
    end

    context 'with arrayed field' do
      let(:options){ { array: true } }

      specify{ expect(subject.read_value_before_type_cast('value', object)).to eq('value') }
      specify{ expect(subject.read_value_before_type_cast('value', object)).not_to be_value_proxy }
      specify{ expect(subject.read_value_before_type_cast('value', object)).not_to respond_to(:elasticize) }

      specify{ expect(subject.read_value_before_type_cast(['value'], object)).to eq(['value']) }
      specify{ expect(subject.read_value_before_type_cast(['value'], object)).not_to be_value_proxy }
      specify{ expect(subject.read_value_before_type_cast(['value'], object)).not_to respond_to(:elasticize) }

      context 'with nil' do
        specify{ expect(subject.read_value_before_type_cast(nil, object)).to be_nil }
        specify{ expect(subject.read_value_before_type_cast(nil, object)).not_to be_value_proxy }
        specify{ expect(subject.read_value_before_type_cast(nil, object)).to respond_to(:elasticize) }

        context 'when default value exists' do
          let(:options){ { array: true, default: 'default' } }

          specify{ expect(subject.read_value_before_type_cast(nil, object)).to eq('default') }
          specify{ expect(subject.read_value_before_type_cast(nil, object)).not_to be_value_proxy }
          specify{ expect(subject.read_value_before_type_cast(nil, object)).not_to respond_to(:elasticize) }
        end
      end
    end
  end

  describe '#type' do
    let(:object){ stub_class('Rubberry::Fields::SomeObject', Rubberry::Fields::Base).new(:name, options) }
    let(:binary){ stub_class('Rubberry::Fields::SomeBinary', Rubberry::Fields::Base).new(:name, options) }

    specify{ expect(object.type).to eq('some_object') }
    specify{ expect(binary.type).to eq('some_binary') }
  end

  describe '#add' do
    specify{ expect{ subject.add('field') }.to change{ subject.children }.from([]).to(['field']) }
  end

  describe '#multi_field?' do
    specify{ expect(subject).not_to be_multi_field }

    context 'when is object and nested' do
      before do
        allow(subject).to receive(:type).and_return('object'.inquiry)
        allow(subject).to receive(:nested?).and_return(true)
      end

      specify{ expect(subject).not_to be_multi_field }
    end

    context 'when is just nested' do
      before{ allow(subject).to receive(:nested?).and_return(true) }
      specify{ expect(subject).to be_multi_field }
    end
  end

  describe '#nested?' do
    specify{ expect(subject).not_to be_nested }

    context do
      before{ subject.add('field') }
      specify{ expect(subject).to be_nested }
    end
  end

  describe '#mappings_hash' do
    specify{ expect(subject.mappings_hash).to eq('name' => { key: 'value' }) }

    context 'when it is multi field' do
      before do
        allow(subject).to receive(:multi_field?).and_return(true)
        allow(subject).to receive(:children).and_return([
          build_field(:raw, type: 'string'), build_field(:sort, type: 'string')
        ])
      end

      specify{ expect(subject.mappings_hash).to eq(
        'name' => {
          key: 'value',
          fields: {
            'raw' => { type: 'string' },
            'sort' => { type: 'string' }
          } }
      ) }
    end

    context 'when it is not multi field' do
      before do
        allow(subject).to receive(:multi_field?).and_return(false)
        allow(subject).to receive(:children).and_return([
          build_field(:raw, type: 'string'), build_field(:sort, type: 'string')
        ])
      end

      specify{ expect(subject.mappings_hash).to eq(
        'name' => {
          key: 'value',
          properties: {
            'raw' => { type: 'string' },
            'sort' => { type: 'string' }
          } }
      ) }
    end
  end
end
