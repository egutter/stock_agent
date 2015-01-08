class StockAgent
  def initialize(stocks, start_cash=1000000.00)
    @total_cash   = start_cash
    @stocks       = stocks
    @transactions = []
    @current_amount_of_stocks = {}
    stocks.each {|stock| @current_amount_of_stocks[stock] = 0 }
  end

  def total_cash
    @total_cash
  end

  def amount_of(stock)
    @current_amount_of_stocks[stock]
  end

  def set_amount_of(stock, value)
    @current_amount_of_stocks[stock] = value
  end

  def buy(stock, date, old_balance=@total_cash)
    price           = Stock.new(stock).price_at(date)
    amount          = Stock.maximum_purchaseable_amount(cash_for_purchase, price)
    price_of_stocks = Stock.price_of(amount, price)

    if @total_cash >= price_of_stocks && amount > 0
      @total_cash = (old_balance - price_of_stocks).round(2)

      set_amount_of(stock, amount_of(stock) + amount)
      save_transaction(date, stock, :buy, amount, price)

      return true
    end

    false
  end

  def sell(stock, date, old_balance=@total_cash)
    price           = Stock.new(stock).price_at(date)
    amount          = amount_of(stock)
    price_of_stocks = Stock.price_of(amount, price)

    if amount > 0
      @total_cash = (old_balance + price_of_stocks).round(2)

      set_amount_of(stock, 0)
      save_transaction(date, stock, :sell, amount, price)

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
    @transactions << "#{date} #{stock} #{action} #{amount} for #{price} (#{Stock.price_of(amount, price)})"
  end

  def list_transactions
    @transactions.each{|t| p t}
  end
end
