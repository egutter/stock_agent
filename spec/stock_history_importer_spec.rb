require 'spec_helper'

describe StockHistoryImporter do
  let(:imported_data) { StockHistoryImporter.run('stock_history.csv') }

  describe '#run' do
    it 'returns a two dimensional array with stock name, date and price' do
      expect(imported_data).to be_a(Hash)
      expect(imported_data['YPF']).to be_a(Hash)
      expect(imported_data['YPF']['2014-07-01']).to be_a(Float)
    end
  end
end
