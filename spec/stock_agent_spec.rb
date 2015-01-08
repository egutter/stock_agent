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

  describe '#cash_for_purchase' do
    context 'purchase limit is default at $1000.00' do
      it 'returns $10.00 if total_cash is 10.00' do
        allow(agent).to receive(:total_cash).and_return(10.00)

        expect(agent.cash_for_purchase).to eq(10.00)
      end

      it 'returns purchase limit $1000.00 if total_cash is 10000.00' do
        allow(agent).to receive(:total_cash).and_return(10000.00)

        expect(agent.cash_for_purchase).to eq(1000.00)
      end
    end
  end
end
