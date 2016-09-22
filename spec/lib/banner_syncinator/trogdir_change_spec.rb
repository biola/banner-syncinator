require 'spec_helper'

describe TrogdirChange do

  describe '#event' do
    it 'returns the event symbol if the corresponding method returns true' do
      described_class::EVENTS = [:test1]
      hash = {}
      trogdir_change = described_class.new(hash)
      allow(trogdir_change).to receive(:test1?) { true }
      expect(trogdir_change.event).to eq(:test1)
    end
  end

end
