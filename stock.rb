class Stock
  def initialize(stock_name, filename = 'stock_history.csv')
    @stock_name = stock_name
    @stock_data ||= StockHistoryImporter.run(filename)
  end

  def name
    @stock_name
  end

  def price_at(date)
    @stock_data[@stock_name][date.to_s]
  end

  def self.price_of(amount, price)
    (amount.round(2) * price.round(2)).round(2)
  end

  def self.calc_percents(number:, percent: 1)
    (number / 100.0) * percent
  end

  def self.diff(value1, value2)
    (value1 - value2).round(2)
  end

  def self.maximum_purchaseable_amount(cash_limit, price)
    return 0 if !cash_limit.is_a?(Numeric) || !price.is_a?(Numeric) || price <= 0 || cash_limit <= 0
    (cash_limit / price).to_i
  end

  def price_change_for_day(day1)
    price_at_day1 = price_at(previous_day(day1))
    price_at_day2 = price_at(day1)

    return if price_at_day1.nil? || price_at_day2.nil?

    (Stock.diff(price_at_day2, price_at_day1) / Stock.calc_percents(number: price_at_day1, percent: 1)).round(2)
  end

  def previous_day(date)
    return if date.day == 1
    prev_day = date - 1

    price_at(prev_day).nil? ? previous_day(prev_day) : prev_day
  end

  def last_business_day_of_month(date)
    @stock_data[@stock_name].reject{ |k,v|
      v.nil? || !k.to_s.match(/#{date.year}-#{date.month.to_s.rjust(2, "0")}-\d{2}/)
    }.keys.sort.last
  end
end
