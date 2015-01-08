require 'spec_helper'

describe StockAgent do
  let(:agent) { StockAgent.new(['YPF']) }

  describe '#new' do
    it 'initializes an instance of Agent' do
      expect(agent).to be_a(StockAgent)
    end
  end

  describe '#total_cash' do
    it 'gets initialized with 1 million' do
      expect(agent.total_cash).to eq(1000000.00)
    end
  end
end
