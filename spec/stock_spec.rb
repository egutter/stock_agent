require 'spec_helper'

describe Stock do
  let(:stock) { Stock.new(source_data, 'YPF') }
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
      expect(stock.instance_variable_get("@data")).to be_a(Hash)
    end
  end

  describe '#price_at' do
    it 'returns the price of a stock on a specific date' do
      expect(stock.price_at('2014-07-01')).to eq(25.5)
    end
  end

  describe '#average_price_until' do
    let(:source_data) {
                        {
                          'YPF' => {
                            '2014-04-01' => 1,
                            '2014-04-02' => 1.5,
                            '2014-04-03' => 1.00,
                            '2014-04-04' => 0,
                            '2014-04-05' => 1,
                            '2014-04-06' => 1,
                            '2014-04-07' => nil,
                            '2014-04-08' => 1,
                            '2014-04-09' => 1,
                            '2014-04-10' => 1,
                            '2014-04-11' => 100
                          }
                        }
                      }

    it 'returns average of 0,875 until the 6th april' do
      expect(stock.average_price_until(Date.parse('2014-04-04'))).to eq(0.875)
    end

    it 'returns average of 0,929 until the 6th april' do
      expect(stock.average_price_until(Date.parse('2014-04-08'))).to eq(0.929)
    end

    it 'returns average of 10.85 until the 6th april' do
      expect(stock.average_price_until(Date.parse('2014-04-11'))).to eq(10.85)
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
end
