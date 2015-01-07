class StockMarket
  def initialize(filename)
    @filename = filename
  end

  def source_data
    @data ||= StockHistoryImporter.run(@filename)
  end



  end
end
