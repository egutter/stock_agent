class StockMarket
  def initialize(filename)
    @filename = filename
    @cash      = 1000000.00
  end

  def data_for(stock: '*', month:, year:)
    _data = source_data.reject{|row| row[1].month != month || row[1].year != year }
    _data = source_data.reject{|row| row[0] != stock } if stock != '*'
    _data
  end

  def source_data
    @data ||= StockHistoryImporter.run(@filename)
  end
end
