require 'spec_helper'

describe Rubberry do
  describe '.configure' do
    specify{ expect{|b| Rubberry.configure(&b) }.to yield_with_args(Rubberry.config) }
  end

  describe '.config' do
    specify{ expect(subject.config).to be_instance_of(Rubberry::Configuration) }
    specify{ expect(subject.config).to eq(subject.config) }
  end

  describe '.wait_for_status' do
  end
end
