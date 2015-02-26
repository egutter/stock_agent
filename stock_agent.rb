require 'pry'

# what are the responsibilities of a Stock Agent?
# Looks like:
# - A stock agent knows the market
# - A stock agent knows all the stocks bought
# - A stock agent knows how to buy or sell a stock
# - A stock agent calculates the total amount of the stocks bought
# - A stock agent knows the different strategies to buy/sell stocks
# etc.etc
# Would be better to extract some of this behavior to other Objects and just make the Agent collaborate with those objects?
# For example:
# Portfolio: stocks bought by the agent
# Sell and Buy operations: logic to buy or sell a stock
# Trading Strategy: logic for a specific strategy

class StockAgent
  def initialize(stocks, start_cash=1000000.00)
    @total_cash   = start_cash
    @transactions = []
    @stocks       = {}
    stocks.each { |stock| @stocks[stock] = {} }
  end

  def stock_market
    @stock_market ||= StockMarket.new
  end

  def stocks
    @stocks.keys
  end

  def stock_assets(stock)
    @stocks[stock] || {}
  end

  def total_cash
    @total_cash
  end

  def amount_of(stock)
    stock_assets(stock).map{|k,v| v[:amount] }.inject(:+) || 0
  end

  def price_of(amount, price)
    return 0 if amount.nil? || price.nil?
    (amount.round(2) * price.round(2)).round(2)
  end

  def amount_of_stock_purchased_at(stock, date)
    return 0 if !stock_assets(stock)[date]
    stock_assets(stock)[date][:amount]
  end

  def maximum_purchaseable_amount(cash_limit, price)
    return 0 if !cash_limit.is_a?(Numeric) || !price.is_a?(Numeric) || price <= 0 || cash_limit <= 0
    (cash_limit / price).to_i
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
    price           = stock_market.get(stock).price_at(date)
    amount          = maximum_purchaseable_amount(cash_for_purchase, price)
    price_of_stocks = price_of(amount, price)

    if @total_cash >= price_of_stocks && amount > 0
      @total_cash = (old_balance - price_of_stocks).round(2)

      set_amount_of_stocks(stock, date, amount, price)
      save_transaction(date, stock, :buy, amount, price)

      return true
    end

    false
  end

  def sell(stock, buy_date, sell_date, old_balance=@total_cash)
    amount          = amount_of_stock_purchased_at(stock, buy_date)

    if amount > 0
      price           = stock_market.get(stock).price_at(sell_date)
      price_of_stocks = price_of(amount, price)

      @total_cash = (old_balance + price_of_stocks).round(2)

      save_transaction(sell_date, stock, :sell, amount, price, buy_date, stock_assets(stock)[buy_date][:price])
      reset_stocks_for(stock, buy_date)

      return true
    end

    false
  end

  def sell_all_of_stock(stock, sell_date)
    stock_assets(stock).each do |buy_date, data|
      sell(stock, buy_date, sell_date)
    end
  end

  def sell_all(sell_date)
    stocks.each do |stock|
      sell_all_of_stock(stock, sell_date)
    end
  end

  def cash_for_purchase(limit=1000.00)
    total_cash >= limit ? limit : total_cash
  end

  def strategy1(date)
    stocks.each do |stock_name|
      stock = stock_market.get(stock_name)
      next unless stock.price_at(date)

      if price_change = stock.price_change_for_day(current_day: date)
        if date.to_s == stock.last_business_day_of_month(date)
          sell_all(date.to_s)
        elsif price_change <= -1.0
          buy(stock_name, date)
        end

        stock_assets(stock_name).each do |buy_date, data|
          if data[:amount] > 0 && price_change >= 2.0
            sell(stock_name, buy_date, date)
          end
        end
      end
    end

    return true
  end

  # If you compare side by side both strategies you can see the code is very similar. Can this code duplication be avoided?
  # Might some other objects be missing which could encapsulate the common behaviour to be reused?
  def strategy2(date)
    stocks.each do |stock_name|
      stock             = stock_market.get(stock_name)
      stock_price_today = stock.price_at(date)
      next unless stock_price_today

      if price_change = stock.price_change_for_day(current_day: date)
        if date.to_s == stock.last_business_day_of_month(date)
          sell_all(date.to_s)
        elsif price_change <= -1.0 || stock_price_today >= (stock.average_price_until(date-1) * 2)
          buy(stock_name, date)
        end
      end

      stock_assets(stock_name).each do |buy_date, data|
        if data[:amount] > 0 && (date-5 >= Date.parse(buy_date))
          sell(stock_name, buy_date, date)
        end
      end
    end

    return true
  end

  def transfer_money(account_balance, value, action)
    case action
    when :buy
      return if account_balance < value
      account_balance - value
    when :sell
      account_balance + value
    else
      raise
    end
  end

  def save_transaction(date, stock, action, amount, price, buy_date=nil, old_stock_price=nil)
    _sell_date = " (bought at #{buy_date} for #{old_stock_price})" if buy_date && old_stock_price
    @transactions << "#{date} #{stock} #{action} #{amount} for #{price} (#{price_of(amount, price)})#{_sell_date}"
  end

  def list_transactions
    @transactions.each{|t| puts t}
  end
end
