require 'spec_helper'

describe StockAgent do
  let(:stocks) { ['YPF'] }
  let(:agent)  { StockAgent.new(stocks) }

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

  describe '#stock_assets' do
    before do
      agent.instance_variable_set(:@stocks, {'YPF' => {'2001'=> :foo}, 'GGAL' => {}})
    end

    it 'returns empty stock transactions for GGAL' do
      expect(agent.stock_assets('GGAL')).to be_a(Hash)
      expect(agent.stock_assets('GGAL')).to be_empty
    end

    it 'returns empty stock transactions for a non existent stock' do
      expect(agent.stock_assets('FOO')).to be_a(Hash)
      expect(agent.stock_assets('FOO')).to be_empty
    end

    it 'returns agent stock transactions for YPF' do
      expect(agent.stock_assets('YPF')).to eq({'2001'=> :foo})
    end

    it 'returns agent stock transactions for YPF' do
      expect(agent.stock_assets('YPF')).to eq({'2001'=> :foo})
    end
  end

  describe '#amount_of_stock_purchased_at' do
    before do
      agent.instance_variable_set(:@stocks, {'YPF' => {'2001-01-01'=> {amount: 10}}, 'GGAL' => {}})
    end

    it 'returns correct number of stock amount' do
      expect(agent.amount_of_stock_purchased_at('YPF', '2001-01-01')).to eq(10)
    end

    it 'returns zero if date param is invalid' do
      expect(agent.amount_of_stock_purchased_at('YPF', 1)).to eq(0)
    end

    it 'returns zero if stock param is invalid' do
      expect(agent.amount_of_stock_purchased_at(1, '2001-01-01')).to eq(0)
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

  describe '#sell' do
    before do
      allow_any_instance_of(Stock).to receive(:price_at).and_return(10.00)
    end

    it 'sell all 10 stocks for $10.00 each' do
      allow(agent).to receive(:amount_of_stock_purchased_at).with(stocks.first, '2001-01-01').and_return(10)

      expect(agent.total_cash).to eq(1000000.00)
      expect(agent.sell('YPF', '2001-01-01', '2014-04-02')).to eq(true)
      expect(agent.total_cash).to eq(1000100.00)
    end

    it 'does not sell if number of stocks is 0' do
      allow(agent).to receive(:amount_of_stock_purchased_at).with(stocks.first, '2001-01-01').and_return(0)

      expect(agent.total_cash).to eq(1000000.00)
      expect(agent.sell('YPF', '2001-01-01', '2014-04-02')).to eq(false)
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

  describe '#set_amount_of_stocks' do
    before do
      expect(agent.instance_variable_get("@stocks")).to eq({'YPF'=>{}})
    end

    it 'is storing the transaction' do
      expect(agent.set_amount_of_stocks('YPF', '2001-01-01', 1337, 13.3)).to eq(true)
      expect(agent.instance_variable_get("@stocks")).to eq({'YPF'=>{'2001-01-01'=>{price: 13.3, amount: 1337}}})
    end

    context 'input is invalid' do
      after do
        expect(agent.instance_variable_get("@stocks")).to eq({'YPF'=>{}})
      end

      it 'does not set if stock name is invalid' do
        expect(agent.set_amount_of_stocks('FOO', '2001-01-01', 1337, 1)).to eq(false)
      end

      it 'does not set if amount is 0' do
        expect(agent.set_amount_of_stocks('YPF', '2001-01-01', 0, 13.3)).to eq(false)
      end

      it 'does not set if amount is nil' do
        expect(agent.set_amount_of_stocks('YPF', '2001-01-01', nil, 0.4)).to eq(false)
      end

      it 'does not set if price is 0' do
        expect(agent.set_amount_of_stocks('YPF', '2001-01-01', 1337, 0)).to eq(false)
      end

      it 'does not set if price is nil' do
        expect(agent.set_amount_of_stocks('YPF', '2001-01-01', 1337, nil)).to eq(false)
      end

      it 'does not set if date format is invalid' do
        expect(agent.set_amount_of_stocks('YPF', '2001-01-022221', 1337, 1)).to eq(false)
      end
    end
  end
end
