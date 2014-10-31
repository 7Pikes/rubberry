require 'spec_helper'

describe Rubberry::Fields::Binary do
  let(:options){ { type: 'binary' } }

  subject{ build_field(:name, options) }

  describe '#type_cast' do
    let(:file){ File.open("#{root}/spec/fixtures/file.txt") }

    specify{ expect(subject.type_cast(nil)).to be_nil }
    specify{ expect(subject.type_cast(Base64.encode64('qwerty'))).to be_instance_of(StringIO) }
    specify{ expect(subject.type_cast(Base64.encode64('qwerty')).read).to eq('qwerty') }
    specify{ expect(subject.type_cast(File.open(file)).read).to eq("blah blah blah\n") }
  end

  describe '#elasticize' do
    let(:file){ File.open("#{root}/spec/fixtures/file.txt") }

    specify{ expect(subject.type_cast(nil).elasticize).to be_nil }
    specify{ expect(subject.type_cast(Base64.encode64('qwerty')).elasticize).to eq("cXdlcnR5\n") }
    specify{ expect(subject.type_cast(File.open(file)).elasticize).to eq("YmxhaCBibGFoIGJsYWgK\n") }
  end
end
