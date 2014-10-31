require 'spec_helper'

describe Rubberry::Fields::Boolean do
  let(:options){ { type: 'boolean' } }

  subject{ build_field(:name, options) }

  describe '#type_cast' do
    specify{ expect(subject.type_cast(nil)).to be_nil }
    specify{ expect(subject.type_cast(true)).to be === true }
    specify{ expect(subject.type_cast(false)).to be === false }
    specify{ expect(subject.type_cast('blah blah')).to be === true }
  end
end
