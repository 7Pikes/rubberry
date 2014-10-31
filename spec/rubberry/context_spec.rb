require 'spec_helper'

describe Rubberry::Context do
  before do
    stub_model('User') do
      mappings do
        field :name
      end
    end
    User.index.create
  end

  after{ User.index.delete }

  let(:context){ Rubberry::Context.new(User, types: 'user') }

  before seed: true do
    User.create!(name: 'Undr')
    User.create!(name: 'Arny')
    User.create!(name: 'Rob')
  end

  describe '#first', seed: true do
    context 'when result is not loaded' do
      subject{ context.first }
      specify{ expect(subject.name).to eq('Undr') }

      context 'and context scoped' do
        subject{ context.order(:name).first }
        specify{ expect(subject.name).to eq('Arny') }
      end

      context 'and size exists' do
        subject{ context.first(2) }
        specify{ expect(subject.map(&:name)).to eq(['Undr', 'Arny']) }
      end
    end

    context 'when result is loaded' do
      subject{ context.tap{|ctx| ctx.to_a }.first }

      specify{ expect(subject.name).to eq('Undr') }

      context 'and context scoped' do
        subject{ context.order(:name).tap{|ctx| ctx.to_a }.first }
        specify{ expect(subject.name).to eq('Arny') }
      end

      context 'and size exists' do
        subject{ context.tap{|ctx| ctx.to_a }.first(2) }
        specify{ expect(subject.map(&:name)).to eq(['Undr', 'Arny']) }
      end
    end
  end

  describe '#count', seed: true do
    context 'when result is not loaded' do
      subject{ context }
      specify{ expect(subject.count).to eq(3) }

      context 'and context scoped' do
        subject{ context.query(term: { name: 'undr' }) }
        specify{ expect(subject.count).to eq(1) }
      end
    end

    context 'when result is loaded' do
      subject{ context.tap{|ctx| ctx.to_a } }

      specify{ expect(subject.count).to eq(3) }

      context 'and context scoped' do
        subject{ context.query(term: { name: 'undr' }).tap{|ctx| ctx.to_a } }
        specify{ expect(subject.count).to eq(1) }
      end
    end
  end

  describe '#took' do
    specify{ expect(context.took).to be >= 0 }
  end

  describe '#delete_all', seed: true do
    specify{ expect{ context.delete_all }.to change{ User.count }.from(3).to(0) }
    specify{ expect{ context.query(term: { name: 'undr' }).delete_all }.to change{ User.count }.from(3).to(2) }
  end

  describe '#loaded?' do
    specify{ expect{ context.to_a }.to change{ context.loaded? }.from(false).to(true) }
  end
end
