require 'spec_helper'

describe StockHistoryImporter do
  let(:imported_data) { StockHistoryImporter.run('stock_history.csv') }

  describe '#run' do
    it 'returns a two dimensional array with stock name, date and price' do
      expect(imported_data).to be_a(Array)
      expect(imported_data.first).to be_a(Array)

      expect(imported_data.first[0]).to be_a(String)
      expect(imported_data.first[1]).to be_a(Date)
      expect(imported_data.first[2]).to be_a(Float)
    end
  end
end
