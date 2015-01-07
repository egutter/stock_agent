require 'spec_helper'

describe StockMarket do
  let(:filename)     { 'dummyfile.csv' }
  let(:source_data)  {
                        {
                          'YPF_2014-07-01' => 25.5,
                          'YPF_2014-07-02' => 28.5,
                          'TS_2014-07-01' => 27.5,
                          'TS_2014-07-02' => 20.1
                        }
                      }
  let(:stock_market) { StockMarket.new(filename) }

  before do
    allow(stock_market).to receive(:source_data).and_return(source_data)
  end

  describe '#new' do
    it 'initializes an instance of StockMarket with a filename param' do
      expect(stock_market).to be_a(StockMarket)
    end

    it 'sets the source data instance variable' do
      expect(stock_market.instance_variable_get("@filename")).to eq(filename)
    end
  end

  describe '#load_source_data' do
    before do
      allow(stock_market).to receive(:source_data).and_call_original
    end

    it 'returns a two dimensional array with stock name, date and price' do
      expect(StockHistoryImporter).to receive(:run).with(filename)

      stock_market.source_data
    end
  end

  describe '#price_at' do
    it 'returns the price of a stock on a specific date' do
      expect(stock_market.price_at(name: 'YPF', date: '2014-07-01')).to eq(25.5)
    end
  end
end
