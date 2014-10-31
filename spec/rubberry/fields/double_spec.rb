require 'spec_helper'

describe Rubberry::Fields::Double do
  let(:options){ { type: 'double' } }

  subject{ build_field(:name, options) }

  describe '#type_cast' do
    specify{ expect(subject.type_cast(nil)).to be_nil }
    specify{ expect(subject.type_cast('a')).to eq(0.0) }
    specify{ expect(subject.type_cast(1)).to eq(1.0) }
    specify{ expect(subject.type_cast(1.2)).to eq(1.2)}
  end
end
