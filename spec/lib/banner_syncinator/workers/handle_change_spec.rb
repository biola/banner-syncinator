require 'spec_helper'

describe Workers::HandleChange do

  before do
    @trogdir_change = double(TrogdirChange)
    allow(TrogdirChange).to receive(:new) { @trogdir_change }
    @null_object = double("null_object").as_null_object
    allow(Trogdir::APIClient::People).to receive(:new).and_return(@null_object)
    described_class.any_instance.stub(:change) { @null_object }
    described_class.any_instance.stub(:person) { @null_object }
    described_class.any_instance.stub(:pidm)
    stub_const("Log", @null_object)
    stub_const("Workers::ChangeFinish", @null_object)
    stub_const("Workrers::ChangeError", @null_object)
    stub_const("Raven", @null_object)
    stub_const("Banner::DB", @null_object)
  end

  describe '#perform' do
    context 'When pidm is null' do
      it 'skips' do
        instance = described_class.new
        instance.stub(:perform_change)
        expect(instance.send(:pidm)).to eq(nil)
        expect(instance).to receive(:perform_change).exactly(0).times
        expect(instance.perform({})).to eq(nil)
      end
    end

    context 'When pidm id not null' do
      it 'calls #perform_change' do
        instance = described_class.new
        instance.stub(:pidm) { 1 }
        instance.stub(:perform_change)
        expect(instance).to receive(:perform_change)
        instance.perform({})
      end
    end

    context 'When @change.event is nil' do
      it 'calls #skip' do
        instance = described_class.new
        instance.stub(:pidm) { 1 }
        change = double("change")
        change.stub(:event) { nil }
        change.stub(:person_uuid)
        instance.stub(:change) { change }
        expect(instance).to receive(:skip)
        instance.perform({})
      end
    end

    context 'When @change.event is not nil' do
      it 'calls the appropriate event method' do
        instance = described_class.new
        change = double("change")
        change.stub(:event) { :test_event }
        change.stub(:person_uuid)
        instance.stub(:pidm) { 1 }
        instance.stub(:change) { change }
        expect(instance).to receive(:test_event)
        instance.perform({})
      end
    end
  end

end
