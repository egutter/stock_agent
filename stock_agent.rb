class StockAgent
  def initialize(stocks, start_cash=1000000.00)
    @total_cash   = start_cash
    @transactions = []
    @stocks = {}
    stocks.each { |stock| @stocks[stock] = {} }
  end

  def stocks
    @stocks.keys
  end

  def total_cash
    @total_cash
  end

  def amount_of(stock)
    return 0 if @stocks[stock].empty?
    @stocks[stock].map{|k,v| v[:amount] }.inject(:+)
  end

  def set_amount_of_stocks(stock, date, amount, price)
    _date = date.to_s

    return false if !_date.match(/\A\d{4}-\d{2}-\d{2}\z/)
    return false if amount.nil? || amount == 0
    return false if price.nil?  || price == 0
    return false if !@stocks[stock] || @stocks[stock].has_key?(_date)

    @stocks[stock][_date]          = {}
    @stocks[stock][_date][:price]  = price
    @stocks[stock][_date][:amount] = amount
    true
  end

  def reset_stocks_for(stock, date)
    @stocks[stock].delete(date)
  end

  def buy(stock, date, old_balance=@total_cash)
    price           = Stock.new(stock).price_at(date)
    amount          = Stock.maximum_purchaseable_amount(cash_for_purchase, price)
    price_of_stocks = Stock.price_of(amount, price)

    if @total_cash >= price_of_stocks && amount > 0
      @total_cash = (old_balance - price_of_stocks).round(2)

      set_amount_of_stocks(stock, date, amount, price)
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

      reset_stocks_for(stock, date)
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
