require 'spec_helper'

describe StockMarket do
  let(:filename)     { 'dummyfile.csv' }
  let(:stock_market) { StockMarket.new(filename) }
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

    end

    end
  end

  end
end
