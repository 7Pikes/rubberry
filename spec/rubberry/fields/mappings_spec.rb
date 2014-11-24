require 'spec_helper'

describe Rubberry::Fields::Mappings do
  subject{ Rubberry::Fields::Mappings.new(EmptyModels) }

  describe '#initialize' do
    specify{ expect(subject.model).to eq(EmptyModels) }
    specify{ expect(subject.dynamic_date_formats.to_a).to eq([]) }
    specify{ expect(subject.dynamic_templates.to_a).to eq([]) }
    specify{ expect(subject.fields).to eq({}) }

    Rubberry::Fields::Mappings::ROOT_SETTINGS.each do |setting_name|
      specify{ expect(subject.send(setting_name)).to be_nil }
    end

    Rubberry::Fields::Mappings::UNDERSCORED_FIELDS.each do |field_name|
      specify{ expect(subject.send(:underscored_fields)[field_name]).to be_nil }
    end

    context 'with document ttl' do
      before{ allow(EmptyModels).to receive(:document_ttl).and_return('2s') }

      specify{ expect(subject.model).to eq(EmptyModels) }
      specify{ expect(subject.dynamic_date_formats.to_a).to eq([]) }
      specify{ expect(subject.dynamic_templates.to_a).to eq([]) }
      specify{ expect(subject.fields).to eq({}) }

      Rubberry::Fields::Mappings::ROOT_SETTINGS.each do |setting_name|
        specify{ expect(subject.send(setting_name)).to be_nil }
      end

      (Rubberry::Fields::Mappings::UNDERSCORED_FIELDS - ['_ttl']).each do |field_name|
        specify{ expect(subject.send(:underscored_fields)[field_name.to_sym]).to be_nil }
      end

      specify{ expect(subject.send(:underscored_fields)[:_ttl]).to eq(enabled: true) }
    end
  end

  shared_examples_for :root_setting do |setting_name|
    describe "##{setting_name}" do
      before{ subject.send(setting_name, 'value') }
      specify{ expect(subject.send(setting_name)).to eq('value') }
    end
  end

  Rubberry::Fields::Mappings::ROOT_SETTINGS.each do |setting_name|
    it_should_behave_like :root_setting, setting_name
  end

  shared_examples_for :underscored_field do |field_name|
    describe "##{field_name}" do
      before{ subject.send(field_name, {}) }
      specify{ expect(subject.send(:underscored_fields)[field_name.to_sym]).to eq({}) }
    end
  end

  Rubberry::Fields::Mappings::UNDERSCORED_FIELDS.each do |field_name|
    it_should_behave_like :underscored_field, field_name
  end

  describe '#date_formats' do
    before{ subject.date_formats 'YYYY-MM-DD', 'YYYY-MM-DD HH:mm' }
    specify{ expect(subject.dynamic_date_formats).to eq(['YYYY-MM-DD', 'YYYY-MM-DD HH:mm']) }
  end

  describe '#dynamic_template' do
    before{ subject.dynamic_template :template1, key: 'key' }
    specify{ expect(subject.dynamic_templates).to eq([{ template1: { key: 'key' } }]) }
  end

  describe '#ttl_enabled?' do
    specify{ expect(subject.ttl_enabled?).to be_falsy }

    context 'with document ttl' do
      before{ allow(EmptyModels).to receive(:document_ttl).and_return('2s') }
      specify{ expect(subject.ttl_enabled?).to be_truthy }

      context 'and turning ttl off' do
        before{ subject._ttl enabled: false }
        specify{ expect(subject.ttl_enabled?).to be_falsy }
      end
    end

    context 'with turning ttl on' do
      before{ subject._ttl enabled: true }
      specify{ expect(subject.ttl_enabled?).to be_truthy }
    end
  end

  describe '#timestamp_enabled?' do
    specify{ expect(subject.timestamp_enabled?).to be_falsy }

    context 'with turning timestamp on' do
      before{ subject._timestamp enabled: true }
      specify{ expect(subject.timestamp_enabled?).to be_truthy }
    end
  end

  describe '#field' do
    let(:field){ build_field(:name1, type: 'string') }

    before{ allow(Rubberry::Fields).to receive(:build).with(anything, anything).and_return(field) }

    context 'when mappings does not contain root field' do
      before{ subject.field(:name1, type: 'string') }

      specify{ expect(subject.fields).to eq('name1' => field) }
      specify{ expect(EmptyModels.new).to respond_to(:name1) }
      specify{ expect(EmptyModels.new).to respond_to(:name1=) }
      specify{ expect(EmptyModels.new).to respond_to(:name1?) }
      specify{ expect(EmptyModels.new).to respond_to(:highlighted_name1) }
      specify{ expect(EmptyModels.new).to respond_to(:highlighted_name1?) }
      specify{ expect(EmptyModels.new).to respond_to(:name1_before_type_cast) }
      specify{ expect(EmptyModels.new).to respond_to(:name1_default) }
    end

    context 'when mappings contains root field' do
      let(:root){ build_field(:root, type: 'string') }

      before do
        subject.send(:stack).push(root)
        subject.field(:name2, type: 'string')
      end

      specify{ expect(root.children).to eq([field]) }
      specify{ expect(EmptyModels.new).not_to respond_to(:name2) }
      specify{ expect(EmptyModels.new).not_to respond_to(:name2=) }
      specify{ expect(EmptyModels.new).not_to respond_to(:name2?) }
      specify{ expect(EmptyModels.new).not_to respond_to(:highlighted_name2) }
      specify{ expect(EmptyModels.new).not_to respond_to(:highlighted_name2?) }
      specify{ expect(EmptyModels.new).not_to respond_to(:name2_before_type_cast) }
      specify{ expect(EmptyModels.new).not_to respond_to(:name2_default) }
    end
  end

  describe '#field?' do
    before{ subject.field(:name, type: 'string') }
    specify{ expect(subject.field?(:name)).to be_truthy }
    specify{ expect(subject.field?('name')).to be_truthy }
    specify{ expect(subject.field?(:blablabla)).to be_falsy }
  end

  describe '#to_hash' do
    before do
      subject._all enabled: true
      subject._analyzer path: 'analyzer'
      subject._routing required: true
      subject._index enabled: true
      subject._size enabled: true
      subject._timestamp enabled: true
      subject._ttl enabled: true, default: '2s'

      subject.dynamic_template :template1, key: 'key'
      subject.date_formats 'YYYY-MM-DD', 'YYYY-MM-DD HH:mm'
      subject.index_analyzer 'autocomplete'
      subject.search_analyzer 'standard'
      subject.date_detection false
      subject.numeric_detection true

      subject.field :name
      subject.field :birthday, type: 'date'
    end

    specify{ expect(subject.to_hash).to eq(
      'empty_models' => {
        properties: { 'name' => { type: 'string'}, 'birthday' => { type: 'date' } },
        _all: { enabled: true },
        _analyzer: { path: 'analyzer'},
        _routing: { required: true },
        _index: { enabled: true },
        _size: { enabled: true },
        _timestamp: { enabled: true },
        _ttl: { enabled: true, default: '2s' },
        index_analyzer: 'autocomplete',
        search_analyzer: 'standard',
        date_detection: false,
        numeric_detection: true,
        dynamic_date_formats: ['YYYY-MM-DD', 'YYYY-MM-DD HH:mm'],
        dynamic_templates: [{ template1: { key: 'key' } }]
      }
    ) }
  end
end
