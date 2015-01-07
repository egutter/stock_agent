require 'spec_helper'

describe StockAgent do
  let(:agent) { StockAgent.new }

  describe '#new' do
    it 'initializes an instance of Agent' do
      expect(agent).to be_a(StockAgent)
    end
  end

  describe '#cash' do
    it 'gets initialized with 1 million' do
      expect(agent.cash).to eq(1000000.00)
    end
  end
end
