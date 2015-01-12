require 'spec_helper'

describe StockAgent do
  let(:stocks) { ['YPF'] }
  let(:agent)  { StockAgent.new(stocks) }

  describe '#new' do
    it 'initializes an instance of Agent' do
      expect(agent).to be_a(StockAgent)
    end
  end


  describe '#maximum_purchaseable_amount' do
    context 'when price is at $10' do
      it 'returns 100 if cash limit is $1000' do
        expect(agent.maximum_purchaseable_amount(1000.00, 10)).to eq(100)
      end

      it 'returns 0 if cash limit is $0' do
        expect(agent.maximum_purchaseable_amount(0, 10)).to eq(0)
      end

      it 'returns 100 if cash limit is -$100' do
        expect(agent.maximum_purchaseable_amount(-100, 10)).to eq(0)
      end

      it 'returns 0 if cash limit is nil' do
        expect(agent.maximum_purchaseable_amount(nil, 10)).to eq(0)
      end
    end

    context 'when cash limit is at $1000' do
      it 'returns 0 if price is at -$10' do
        expect(agent.maximum_purchaseable_amount(1000.00, -10)).to eq(0)
      end

      it 'returns 0 if price is at $0' do
        expect(agent.maximum_purchaseable_amount(1000.00, 0)).to eq(0)
      end

      it 'returns 0 if price is at $26' do
        expect(agent.maximum_purchaseable_amount(1000.00, 26)).to eq(38)
      end

      it 'returns 0 if price is at nil' do
        expect(agent.maximum_purchaseable_amount(1000.00, nil)).to eq(0)
      end
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

  describe '#price_of' do
    it 'returns the total price of nil stocks' do
      expect(agent.price_of(12, 12)).to eq(144.0)
    end

    it 'returns the total price of stocks' do
      expect(agent.price_of(10.453, 12.1234)).to eq(126.65)
    end

    it 'returns the total price of nil stocks' do
      expect(agent.price_of(nil, 12.1234)).to eq(0)
    end

    it 'returns the total price of nil stocks' do
      expect(agent.price_of(12, nil)).to eq(0)
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
      agent.set_amount_of_stocks('YPF', '2001-01-01', 10, 13.3)

      expect(agent.total_cash).to eq(1000000.00)
      expect(agent.sell('YPF', '2001-01-01', '2014-04-02')).to eq(true)
      expect(agent.total_cash).to eq(1000100.00)
    end

    it 'does not sell if number of stocks is 0' do
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

  context 'agent owns multiple stocks' do
    let(:stocks) { ['YPF', 'FOO', 'BAR'] }

    before do
      agent.set_amount_of_stocks('YPF', '2001-01-01', 1337, 13.3)
      agent.set_amount_of_stocks('YPF', '2001-01-10', 1, 20.0)
      agent.set_amount_of_stocks('FOO', '2001-01-30', 42, 0.1)
      agent.set_amount_of_stocks('BAR', '2001-01-07', 1111, 1234.9)

      expect(agent.amount_of('YPF')).to eq(1338)

      allow_any_instance_of(Stock).to receive(:price_at).with('2001-01-31').and_return(13.00)
    end

    describe '#sell_all' do
      it 'sells all stocks on the 2001-01-31' do
        agent.sell_all('2001-01-31')

        expect(agent.amount_of('YPF')).to eq(0)
        expect(agent.amount_of('FOO')).to eq(0)
        expect(agent.amount_of('BAR')).to eq(0)
      end
    end

    describe '#sell_all_of_stock' do
      it 'sells all YPF stocks' do
        agent.sell_all_of_stock('YPF', '2001-01-31')

        expect(agent.amount_of('YPF')).to eq(0)
        expect(agent.amount_of('FOO')).to eq(42)
        expect(agent.amount_of('BAR')).to eq(1111)
      end
    end
  end

  describe '#strategy1' do
    context 'has 1337 stocks of YPF' do
      let(:source_data)  {
                        {
                          'YPF' => {
                            '2014-04-01' => 25.0,
                            '2014-04-02' => 25.25,
                            '2014-04-03' => 25.76,
                            '2014-04-04' => 26.53
                          }
                        }
                      }

      before do
        agent.set_amount_of_stocks('YPF', '2001-04-01', 1337, 13.3)
        expect(agent.amount_of('YPF')).to eq(1337)

        allow(StockHistoryImporter).to receive(:run).and_return(source_data)
      end

      it 'does not sell a stocks if price rose only 1%' do
        expect(agent.strategy1(Date.parse('2014-04-02'))).to eq(true)
        expect(agent.amount_of('YPF')).to eq(1337)
      end

      it 'sells a stock if price rose 2%' do
        expect(agent.strategy1(Date.parse('2014-04-03'))).to eq(true)
        expect(agent.amount_of('YPF')).to eq(0)
      end

      it 'sells a stock if price rose 3%' do
        expect(agent.strategy1(Date.parse('2014-04-04'))).to eq(true)
        expect(agent.amount_of('YPF')).to eq(0)
      end
    end

    context 'price drop' do
      it 'does not buy a stock if price dropped 0.9%' do
        allow_any_instance_of(Stock).to receive(:price_change_for_day).and_return(-0.99)

        expect(agent.amount_of('YPF')).to eq(0)
        expect(agent.strategy1(Date.parse('2014-04-02'))).to eq(true)
        expect(agent.amount_of('YPF')).to eq(0)
      end

      it 'buys a stock if price dropped 1%' do
        allow_any_instance_of(Stock).to receive(:price_change_for_day).and_return(-1.0)

        expect(agent.amount_of('YPF')).to eq(0)
        expect(agent.strategy1(Date.parse('2014-04-02'))).to eq(true)
        expect(agent.amount_of('YPF')).to eq(31)
      end

      it 'buys a stock if price dropped 2%' do
        allow_any_instance_of(Stock).to receive(:price_change_for_day).and_return(-2.0)

        expect(agent.amount_of('YPF')).to eq(0)
        expect(agent.strategy1(Date.parse('2014-04-02'))).to eq(true)
        expect(agent.amount_of('YPF')).to eq(31)
      end
    end

    it 'sells all stocks at the last day of month' do
      agent.set_amount_of_stocks('YPF', '2001-04-01', 1337, 13.3)
      agent.set_amount_of_stocks('YPF', '2001-04-02', 13, 13.3)

      expect(agent.amount_of('YPF')).to eq(1350)
      expect(agent.strategy1(Date.parse('2014-04-30'))).to eq(true)
      expect(agent.amount_of('YPF')).to eq(0)
    end
  end

  describe '#strategy2' do
    context 'average quotation buy cases' do
      let(:source_data) {
                          {
                            'YPF' => {
                              '2014-04-01' => 25.0,
                              '2014-04-02' => 25,
                              '2014-04-03' => 50,
                              '2014-04-04' => 10,
                              '2014-04-05' => 30,
                              '2014-04-06' => 0.1,
                              '2014-04-07' => nil,
                              '2014-04-08' => 100.0,
                              '2014-04-09' => 26.53,
                              '2014-04-10' => 26.53,
                              '2014-04-11' => 26.53
                            }
                          }
                        }

      before do
        allow(StockHistoryImporter).to receive(:run).and_return(source_data)
      end

      it 'buy 20 for 50 if the price is equal to at least twice the average quotation of the share' do
        expect(agent.strategy2(Date.parse('2014-04-03'))).to eq(true)
        expect(agent.amount_of('YPF')).to eq(20)
      end

      it 'dont buy if the price less than twice the average quotation of the share' do
        expect(agent.strategy2(Date.parse('2014-04-05'))).to eq(true)
        expect(agent.amount_of('YPF')).to eq(0)
      end

      it 'buy 10 for 100 if the price is higher than twice the average quotation of the share' do
        expect(agent.strategy2(Date.parse('2014-04-08'))).to eq(true)
        expect(agent.amount_of('YPF')).to eq(10)
      end
    end

    context 'price drop' do
      it 'does not buy a stock if price dropped 0.9%' do
        allow_any_instance_of(Stock).to receive(:price_change_for_day).and_return(-0.99)

        expect(agent.amount_of('YPF')).to eq(0)
        expect(agent.strategy2(Date.parse('2014-04-02'))).to eq(true)
        expect(agent.amount_of('YPF')).to eq(0)
      end

      it 'buys a stock if price dropped 1%' do
        allow_any_instance_of(Stock).to receive(:price_change_for_day).and_return(-1.0)

        expect(agent.amount_of('YPF')).to eq(0)
        expect(agent.strategy2(Date.parse('2014-04-02'))).to eq(true)
        expect(agent.amount_of('YPF')).to eq(31)
      end

      it 'buys a stock if price dropped 2%' do
        allow_any_instance_of(Stock).to receive(:price_change_for_day).and_return(-2.0)

        expect(agent.amount_of('YPF')).to eq(0)
        expect(agent.strategy2(Date.parse('2014-04-02'))).to eq(true)
        expect(agent.amount_of('YPF')).to eq(31)
      end
    end

    context 'sell' do
      let(:stocks) { ['YPF', 'GGAL'] }

      before do
        agent.set_amount_of_stocks('YPF', '2014-04-01', 1337, 13.3)
        agent.set_amount_of_stocks('GGAL', '2014-04-01', 31337, 13.3)
      end

      it 'sells a stock after 5 days having purchased' do
        allow_any_instance_of(Stock).to receive(:price_at).and_return(13.00)

        expect(agent.strategy2(Date.parse('2014-04-06'))).to eq(true)
        expect(agent.amount_of('YPF')).to eq(0)
      end

      it 'sells all stocks at the last day of the month' do
        allow_any_instance_of(Stock).to receive(:price_at).and_return(10.0)
        agent.set_amount_of_stocks('YPF', '2014-04-28', 13, 13.3)

        expect(agent.strategy2(Date.parse('2014-04-30'))).to eq(true)
        expect(agent.amount_of('YPF')).to eq(0)
      end

      it 'does not sell all stocks at the day before the last day of the month' do
        allow_any_instance_of(Stock).to receive(:price_at).and_return(10.0)
        agent.set_amount_of_stocks('YPF', '2014-04-28', 13, 13.3)

        expect(agent.strategy2(Date.parse('2014-04-29'))).to eq(true)
        expect(agent.amount_of('YPF')).to eq(13)
      end
    end
  end
end
