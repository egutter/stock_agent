class StockMarket
  def initialize(filename)
    @filename = filename
  end

  def source_data
    @data ||= StockHistoryImporter.run(@filename)
  end

  def price_at(name:, date:)
    source_data["#{name}_#{date}"]
  end
end
