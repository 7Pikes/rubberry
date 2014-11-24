require 'spec_helper'

describe Rubberry::Stateful, 'object' do
  let(:model){ UserEvent }

  context 'when initialized without attributes' do
    subject{ model.new }

    specify{ expect(subject).not_to be_updatable }
    specify{ expect(subject).not_to be_changed }
    specify{ expect(subject).not_to be_creatable }
    specify{ expect(subject).not_to be_readonly }
    specify{ expect(subject).not_to be_destroyed }
    specify{ expect(subject).not_to be_persisted }
    specify{ expect(subject).to be_new_record }
  end

  context 'when initialized with attributes' do
    subject{ model.new(name: 'name') }

    specify{ expect(subject).not_to be_updatable }
    specify{ expect(subject).to be_changed }
    specify{ expect(subject).to be_creatable }
    specify{ expect(subject).not_to be_readonly }
    specify{ expect(subject).not_to be_destroyed }
    specify{ expect(subject).not_to be_persisted }
    specify{ expect(subject).to be_new_record }
  end

  context 'when instantiate' do
    let(:doc){ { '_source' => { 'name' => 'value' } } }

    subject{ model.instantiate(doc) }

    specify{ expect(subject).not_to be_updatable }
    specify{ expect(subject).not_to be_changed }
    specify{ expect(subject).not_to be_creatable }
    specify{ expect(subject).not_to be_readonly }
    specify{ expect(subject).not_to be_destroyed }
    specify{ expect(subject).to be_persisted }
    specify{ expect(subject).not_to be_new_record }
  end

  context do
    subject do
      model.new.tap do |m|
        m.instance_exec do
          @new_record = false
          @destroyed = false
          @readonly = false
        end
      end
    end

    before do
      allow(subject).to receive(:almost_expired?).and_return(true)
    end

    context do
      before{ allow(subject).to receive(:persisted?).and_return(false) }

      context 'when changed' do
        before{ allow(subject).to receive(:changed?).and_return(true) }
        specify{ expect(subject).not_to be_updatable }

        context 'and persisted' do
          before{ allow(subject).to receive(:persisted?).and_return(true) }
          specify{ expect(subject).not_to be_updatable }

          context 'and not almost expired' do
            before{ allow(subject).to receive(:almost_expired?).and_return(false) }
            specify{ expect(subject).to be_updatable }
          end
        end
      end

      context 'when persisted' do
        before{ allow(subject).to receive(:persisted?).and_return(true) }
        specify{ expect(subject).not_to be_updatable }

        context 'and changed' do
          before{ allow(subject).to receive(:changed?).and_return(true) }
          specify{ expect(subject).not_to be_updatable }

          context 'and not almost expired' do
            before{ allow(subject).to receive(:almost_expired?).and_return(false) }
            specify{ expect(subject).to be_updatable }
          end
        end
      end

      context 'when not almost expired' do
        before{ allow(subject).to receive(:almost_expired?).and_return(false) }
        specify{ expect(subject).not_to be_updatable }

        context 'and persisted' do
          before{ allow(subject).to receive(:persisted?).and_return(true) }
          specify{ expect(subject).not_to be_updatable }

          context 'and changed' do
            before{ allow(subject).to receive(:changed?).and_return(true) }
            specify{ expect(subject).to be_updatable }
          end
        end
      end
    end

    context do
      before{ allow(subject).to receive(:persisted?).and_return(false) }

      context 'when new_record' do
        before{ allow(subject).to receive(:new_record?).and_return(true) }
        specify{ expect(subject).not_to be_creatable }

        context 'and changed' do
          before{ allow(subject).to receive(:changed?).and_return(true) }
          specify{ expect(subject).to be_creatable }
        end
      end

      context 'when changed' do
        before{ allow(subject).to receive(:changed?).and_return(true) }
        specify{ expect(subject).not_to be_creatable }

        context 'and new_record' do
          before{ allow(subject).to receive(:new_record?).and_return(true) }
          specify{ expect(subject).to be_creatable }
        end
      end
    end

    context do
      context 'when not persisted' do
        before{ allow(subject).to receive(:persisted?).and_return(false) }
        specify{ expect(subject).not_to be_destroyable }
      end

      context 'when persisted' do
        before{ allow(subject).to receive(:persisted?).and_return(true) }
        specify{ expect(subject).to be_destroyable }
      end
    end

    context do
      specify{ expect(subject).to be_persisted }

      context 'when new_record' do
        before{ allow(subject).to receive(:new_record?).and_return(true) }
        specify{ expect(subject).not_to be_persisted }
      end

      context 'when destroyed' do
        before{ allow(subject).to receive(:destroyed?).and_return(true) }
        specify{ expect(subject).not_to be_persisted }
      end
    end
  end
end
