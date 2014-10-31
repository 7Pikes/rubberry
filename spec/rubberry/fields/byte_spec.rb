require 'spec_helper'

describe Rubberry::Fields::Byte do
  let(:options){ { type: 'byte' } }

  subject{ build_field(:name, options) }

  describe '#type_cast' do
    specify{ expect(subject.type_cast(nil)).to be_nil }
    specify{ expect(subject.type_cast('a')).to eq(97) }
    specify{ expect(subject.type_cast(1)).to eq(1) }
    specify{ expect(subject.type_cast('abc')).to eq(97)}
    specify{ expect(subject.type_cast(1.2)).to eq(1)}
  end
end
