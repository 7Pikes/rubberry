require 'spec_helper'

describe Rubberry::Fields::Proxy do
  let(:field){ build_field(:name) }

  describe '.new' do
    context 'with nil' do
      subject{ Rubberry::Fields::Proxy.new(nil, field) }
      specify{ expect(subject).to be_nil }
      specify{ expect(subject).not_to be_value_proxy }
    end

    context 'with false' do
      subject{ Rubberry::Fields::Proxy.new(false, field) }
      specify{ expect(subject).to be_falsy }
      specify{ expect(subject).not_to be_value_proxy }

      context 'and as array' do
        let(:field){ build_field(:name, array: true) }
        specify{ expect(subject).to eq(false) }
        specify{ expect(subject).to be_value_proxy }
      end
    end

    context 'with any object' do
      subject{ Rubberry::Fields::Proxy.new('object', field) }
      specify{ expect(subject).to eq('object') }
      specify{ expect(subject).to be_value_proxy }
    end
  end

  describe '#value_proxy?' do
    subject{ Rubberry::Fields::Proxy.new('object', field) }
    specify{ expect(subject).to be_value_proxy }
  end

  describe '#==' do
    let(:same_proxy){ subject }
    let(:proxy){ Rubberry::Fields::Proxy.new('object', field) }
    let(:another_proxy){ Rubberry::Fields::Proxy.new('another object', field) }

    subject{ Rubberry::Fields::Proxy.new('object', field) }

    specify{ expect(subject == proxy).to be_truthy }
    specify{ expect(subject == 'object').to be_truthy }
    specify{ expect(subject == same_proxy).to be_truthy }
    specify{ expect(subject == another_proxy).to be_falsy }
    specify{ expect(subject == 'another object').to be_falsy }
  end
end
