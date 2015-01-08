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

  describe '#buy' do
    before do
      allow_any_instance_of(Stock).to receive(:price_at).and_return(10.00)
    end

    it 'purchase stocks for $1000.00' do
      expect(agent.total_cash).to eq(1000000.00)
      expect(agent.buy('YPF', '2014-04-02')).to eq(true)
      expect(agent.total_cash).to eq(999000.00)
    end

    context 'agent has $1.00 start cash' do
      let(:agent) { StockAgent.new(['YPF'], 1.00) }

      it 'is not purchasing stocks' do
        expect(agent.total_cash).to eq(1.00)
        expect(agent.buy('YPF', '2014-04-02')).to eq(false)
        expect(agent.total_cash).to eq(1.00)
      end
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

  describe '#transfer_money' do
    context ':buy' do
      let(:action) { :buy }

      it 'returns nil if balance is smaller than value' do
        expect(agent.transfer_money(100,1000, action)).to eq(nil)
      end

      it 'returns $900.00 if balance is $1000 and value $100' do
        expect(agent.transfer_money(1000,100, action)).to eq(900)
      end

      it 'returns $0.00 if balance is $1000 and value $1000' do
        expect(agent.transfer_money(1000,1000, action)).to eq(0)
      end
    end

    context ':sell' do
      let(:action) { :sell }

      it 'returns $1100.00 if balance is $1000 and value $100' do
        expect(agent.transfer_money(1000, 100, action)).to eq(1100)
      end

      it 'returns $0.00 if balance is $1000 and value $100' do
        expect(agent.transfer_money(1000, 1000, action)).to eq(2000)
      end
    end
  end
end
