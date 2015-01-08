class StockAgent
  def initialize(stocks, start_cash=1000000.00)
    @total_cash   = start_cash
    @stocks       = stocks
  end

  def total_cash
    @total_cash
  end

  def buy(stock, date, old_balance=@total_cash)
    price           = Stock.new(stock).price_at(date)
    amount          = Stock.maximum_amount(cash_for_purchase, price)
    price_of_stocks = amount * price

    if @total_cash >= price_of_stocks && amount > 0
      @total_cash = old_balance - price_of_stocks
      save_transaction(date, stock, :buy, amount, price)

      return true
    end

    false
  end

  def cash_for_purchase(limit=1000.00)
    total_cash >= limit ? limit : total_cash
  end

  def transfer_money(account_balance, value, action)
    case action
    when :buy
      return if account_balance < value
      return account_balance - value
    when :sell
      return account_balance + value
    end
  end

  def save_transaction(date, stock, action, amount, price)
  end
end
