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

  def calc_percents(number:, percent: 1)
    (number / 100.0) * percent
  end

  def diff(value1, value2)
    (value1 - value2).round(1)
  end
end
