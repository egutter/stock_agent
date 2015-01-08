require 'spec_helper'

describe Stock do
  let(:stock) { Stock.new('YPF') }
  let(:source_data)  {
                        {
                          'YPF' => {
                            '2014-07-01' => 25.5,
                            '2014-07-02' => 28.5,
                          },
                          'TS' => {
                            '2014-07-01' => 27.5,
                            '2014-07-02' => 20.1
                          }
                        }
                      }

  before do
    allow(StockHistoryImporter).to receive(:run).and_return(source_data)
  end

  describe '#new' do
    it 'returns an instance of stock' do
      expect(stock).to be_a(Stock)
    end

    it 'loads the stock_data on initialize' do
      expect(stock.instance_variable_get("@stock_data")).to be_a(Hash)
    end
  end

  describe '#price_at' do
    it 'returns the price of a stock on a specific date' do
      expect(stock.price_at('2014-07-01')).to eq(25.5)
    end
  end

  describe '#diff' do
    it 'calculates a negative difference between two decimal numbers' do
      expect(stock.diff(1.2, 2.2)).to eq(-1.0)
    end

    it 'calculates a positive difference between two decimal numbers' do
      expect(stock.diff(1.0, 0.2)).to eq(0.8)
    end

    it 'rounds the result to two decimal places' do
      expect(stock.diff(1.123456789, 0.23456789)).to eq(0.89)
    end

    it 'calculates the diff between two zeroes' do
      expect(stock.diff(0, 0)).to eq(0.0)
    end

    it 'calculates the diff between a positive and a negative number' do
      expect(stock.diff(5, -10)).to eq(15.0)
    end

    it 'calculates the diff between a negative and a positive number' do
      expect(stock.diff(-10, 5)).to eq(-15.0)
    end
  end

  describe '#calc_percents' do
    context 'number param is set to 25.0' do
      let(:number_param) { 25.0 }

      it 'returns 15% of a number' do
        expect(stock.calc_percents(number: number_param, percent: 15)).to eq(3.75)
      end

      it 'returns -15% of a number' do
        expect(stock.calc_percents(number: number_param, percent: -15)).to eq(-3.75)
      end

      it 'returns 0% of a number' do
        expect(stock.calc_percents(number: number_param, percent: 0)).to eq(0.0)
      end

      it 'returns 0.1% of a number' do
        expect(stock.calc_percents(number: number_param, percent: 0.1)).to eq(0.025)
      end
    end

    context 'percent param default is 1' do
      it 'returns 1% of 1337' do
        expect(stock.calc_percents(number: 1337)).to eq(13.37)
      end

      it 'returns 1% of 5' do
        expect(stock.calc_percents(number: 5)).to eq(0.05)
      end

      it 'returns 1% of 0.0' do
        expect(stock.calc_percents(number: 0.0)).to eq(0.0)
      end

      it 'returns 1% of 0.1' do
        expect(stock.calc_percents(number: 0.1)).to eq(0.001)
      end

      it 'returns 1% of -7' do
        expect(stock.calc_percents(number: -7)).to eq(-0.07)
      end
    end
  end


  describe '#price_change_for_day' do
    it 'returns price change of 1% compare to previous day' do
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-01')).and_return(26.0)
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-02')).and_return(26.26)

      expect(stock.price_change_for_day(Date.parse('2014-07-02'))).to eq(1.0)
    end

    it 'returns nil if previous day provides no data' do
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-01')).and_return(nil)
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-02')).and_return(26.26)
      allow(stock).to receive(:price_at).with(nil).and_return(nil)

      expect(stock.price_change_for_day(Date.parse('2014-07-02'))).to eq(nil)
    end

    it 'returns nil if day provides no data' do
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-01')).and_return(26.0)
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-02')).and_return(nil)

      expect(stock.price_change_for_day(Date.parse('2014-07-02'))).to eq(nil)
    end

    it 'returns 0.0% price is consistent' do
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-01')).and_return(26.0)
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-02')).and_return(26.0)

      expect(stock.price_change_for_day(Date.parse('2014-07-02'))).to eq(0.0)
    end
  end

  describe '#previous_day (with data)' do
    it 'should return the 2014-07-01' do
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-01')).and_return(26.0)
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-02')).and_return(26.0)

      expect(stock.previous_day(Date.parse('2014-07-02'))).to eq(Date.parse('2014-07-01'))
    end

    it 'should return the 2014-07-01' do
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-01')).and_return(26.0)
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-02')).and_return(nil)
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-03')).and_return(nil)
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-04')).and_return(26.0)

      expect(stock.previous_day(Date.parse('2014-07-04'))).to eq(Date.parse('2014-07-01'))
    end

    it 'should return nil if no previous day with data can be found' do
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-01')).and_return(nil)
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-02')).and_return(nil)
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-03')).and_return(nil)
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-04')).and_return(26.0)

      expect(stock.previous_day(Date.parse('2014-07-04'))).to eq(nil)
    end
  end

  describe '#maximum_amount' do
    context 'when stock price is at $10' do
      it 'returns 100 if cash limit is $1000' do
        expect(stock.maximum_amount(1000.00, 10)).to eq(100)
      end

      it 'returns 0 if cash limit is $0' do
        expect(stock.maximum_amount(0, 10)).to eq(0)
      end

      it 'returns 100 if cash limit is -$100' do
        expect(stock.maximum_amount(-100, 10)).to eq(0)
      end

      it 'returns 0 if cash limit is nil' do
        expect(stock.maximum_amount(nil, 10)).to eq(0)
      end
    end

    context 'when cash limit is at $1000' do
      it 'returns 0 if stock price is at -$10' do
        expect(stock.maximum_amount(1000.00, -10)).to eq(0)
      end

      it 'returns 0 if stock price is at $0' do
        expect(stock.maximum_amount(1000.00, 0)).to eq(0)
      end

      it 'returns 0 if stock price is at $26' do
        expect(stock.maximum_amount(1000.00, 26)).to eq(38)
      end

      it 'returns 0 if stock price is at nil' do
        expect(stock.maximum_amount(1000.00, nil)).to eq(0)
      end
    end
  end
end
