class StockAgent
  def initialize(stocks)
    @total_cash   = 1000000.00
    @stocks = stocks
  end

  def total_cash
    @total_cash
  end

  def cash_for_purchase(limit=1000.00)
    total_cash >= limit ? limit : total_cash
  end
end
