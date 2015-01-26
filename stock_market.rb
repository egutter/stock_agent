class StockMarket
  def initialize
    @history ||= StockHistoryImporter.run('stock_history.csv')
  end

  def history
    @history
  end

  def get(name)
    Stock.new(history, name)
  end
end
