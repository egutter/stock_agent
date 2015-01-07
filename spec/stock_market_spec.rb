require 'spec_helper'

describe StockMarket do
  let(:filename)     { 'stock_history.csv' }
  let(:source_data)  { [['YPF', Date.parse('2014-07-01'), 25.5]] }
  let(:stock_market) { StockMarket.new(filename) }

  before do
    allow(stock_market).to receive(:source_data).and_return(source_data)
  end

  describe '#new' do
    it 'receives one parameter with stock filename' do
      expect(stock_market).to be_a(StockMarket)
    end

    it 'sets the source data instance variable' do
      expect(stock_market.instance_variable_get("@file_name")).to eq(filename)
    end
  end

  describe '#data_for' do
    context 'source data provides only data for july 2014' do
      it 'returns array of data for the given month and year' do
        expect(stock_market.data_for(month: 7, year: 2014)).to eq(source_data)
      end

      it 'returns empty array for june 2014' do
        expect(stock_market.data_for(month: 6, year: 2014)).to be_empty
      end

      it 'returns empty array for july 2015' do
        expect(stock_market.data_for(month: 7, year: 2015)).to be_empty
      end
    end
  end

  describe '#load_source_data' do
    before do
      allow(stock_market).to receive(:source_data).and_call_original
    end

    it 'returns a two dimensional array with stock name, date and price' do
      expect(stock_market.source_data).to be_a(Array)
      expect(stock_market.source_data.first).to be_a(Array)

      expect(stock_market.source_data.first[0]).to be_a(String)
      expect(stock_market.source_data.first[1]).to be_a(Date)
      expect(stock_market.source_data.first[2]).to be_a(Float)
    end
  end
end
