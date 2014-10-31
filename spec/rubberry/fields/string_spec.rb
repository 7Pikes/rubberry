require 'spec_helper'

describe Rubberry::Fields::String do
  let(:options){ { type: 'string' } }

  subject{ build_field(:name, options) }

  describe '#type_cast' do
    specify{ expect(subject.type_cast(nil)).to be_nil }
    specify{ expect(subject.type_cast('a')).to eq('a') }
    specify{ expect(subject.type_cast(1)).to eq('1') }
    specify{ expect(subject.type_cast(1.2)).to eq('1.2')}
  end
end
