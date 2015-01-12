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

  describe '#price_change_for_day' do
    before do
      allow(stock).to receive(:price_at).with(Date.parse('2014-07-01')).and_return(26.0)
    end

    context 'using default ref_day param (previous day)' do
      it 'returns price change of 1%' do
        allow(stock).to receive(:price_at).with(Date.parse('2014-07-02')).and_return(26.26)

        expect(stock.price_change_for_day(current_day: Date.parse('2014-07-02'))).to eq(1.0)
      end

      it 'returns nil if previous day provides no data' do
        allow(stock).to receive(:price_at).with(Date.parse('2014-07-01')).and_return(nil)
        allow(stock).to receive(:price_at).with(Date.parse('2014-07-02')).and_return(26.26)
        allow(stock).to receive(:price_at).with(nil).and_return(nil)

        expect(stock.price_change_for_day(current_day: Date.parse('2014-07-02'))).to eq(nil)
      end

      it 'returns nil if day provides no data' do
        allow(stock).to receive(:price_at).with(Date.parse('2014-07-02')).and_return(nil)

        expect(stock.price_change_for_day(current_day: Date.parse('2014-07-02'))).to eq(nil)
      end

      it 'returns 0.0% price is consistent' do
        allow(stock).to receive(:price_at).with(Date.parse('2014-07-02')).and_return(26.0)

        expect(stock.price_change_for_day(current_day: Date.parse('2014-07-02'))).to eq(0.0)
      end
    end

    context 'using ref_day param' do
      it 'returns price change of 1%' do
        allow(stock).to receive(:price_at).with(Date.parse('2014-07-02')).and_return(26.26)

        expect(stock.price_change_for_day(current_day: Date.parse('2014-07-02'))).to eq(1.0)
      end

      it 'returns nil if previous day provides no data' do
        allow(stock).to receive(:price_at).with(Date.parse('2014-07-01')).and_return(nil)
        allow(stock).to receive(:price_at).with(Date.parse('2014-07-02')).and_return(26.26)
        allow(stock).to receive(:price_at).with(nil).and_return(nil)

        expect(stock.price_change_for_day(current_day: Date.parse('2014-07-02'))).to eq(nil)
      end

      it 'returns nil if day provides no data' do
        allow(stock).to receive(:price_at).with(Date.parse('2014-07-02')).and_return(nil)

        expect(stock.price_change_for_day(current_day: Date.parse('2014-07-02'), ref_day: Date.parse('2014-07-01'))).to eq(nil)
      end

      it 'returns 0.0% price is consistent' do
        allow(stock).to receive(:price_at).with(Date.parse('2014-07-04')).and_return(26.0)

        expect(stock.price_change_for_day(current_day: Date.parse('2014-07-04'), ref_day: Date.parse('2014-07-01'))).to eq(0.0)
      end
    end
  end

  context 'business days' do
    let(:source_data) {
                        {
                          'YPF' => {
                            '2014-07-07' => 25.5,
                            '2014-07-10' => nil,
                            '2014-07-03' => 28.5,
                            '2014-07-05' => nil,
                            '2014-07-30' => 27.5,
                            '2014-07-31' => nil,
                            '2014-07-02' => 20.1
                          }
                        }
                      }

    describe '#business_days_of_month' do
      it 'returns a sorted array with business days of month' do
        expect(stock.business_days_of_month(Date.parse('2014-07-02'))).to eq(["2014-07-02", "2014-07-03", "2014-07-07", "2014-07-30"])
      end

      it 'returns array business days for given month' do
        expect(stock.business_days_of_month(Date.parse('2014-08-02'))).to be_empty
      end
    end

    describe '#first_business_day_of_month' do
      it 'returns nil if no data exists for a month' do
        expect(stock.first_business_day_of_month(Date.parse('2014-08-02'))).to eq(nil)
      end

      it 'returns the first day of month with data' do
        expect(stock.first_business_day_of_month(Date.parse('2014-07-02'))).to eq('2014-07-02')
      end
    end

    describe '#last_business_day_of_month' do
      it 'returns the last day of month with data' do
        expect(stock.last_business_day_of_month(Date.parse('2014-07-02'))).to eq('2014-07-30')
      end
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

  describe '.maximum_purchaseable_amount' do
    context 'when stock price is at $10' do
      it 'returns 100 if cash limit is $1000' do
        expect(Stock.maximum_purchaseable_amount(1000.00, 10)).to eq(100)
      end

      it 'returns 0 if cash limit is $0' do
        expect(Stock.maximum_purchaseable_amount(0, 10)).to eq(0)
      end

      it 'returns 100 if cash limit is -$100' do
        expect(Stock.maximum_purchaseable_amount(-100, 10)).to eq(0)
      end

      it 'returns 0 if cash limit is nil' do
        expect(Stock.maximum_purchaseable_amount(nil, 10)).to eq(0)
      end
    end

    context 'when cash limit is at $1000' do
      it 'returns 0 if stock price is at -$10' do
        expect(Stock.maximum_purchaseable_amount(1000.00, -10)).to eq(0)
      end

      it 'returns 0 if stock price is at $0' do
        expect(Stock.maximum_purchaseable_amount(1000.00, 0)).to eq(0)
      end

      it 'returns 0 if stock price is at $26' do
        expect(Stock.maximum_purchaseable_amount(1000.00, 26)).to eq(38)
      end

      it 'returns 0 if stock price is at nil' do
        expect(Stock.maximum_purchaseable_amount(1000.00, nil)).to eq(0)
      end
    end
  end
end
