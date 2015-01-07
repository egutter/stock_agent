class Stock
  def initialize(stock_name, filename = 'stock_history.csv')
    @stock_name = stock_name
    @stock_data ||= StockHistoryImporter.run(filename)
  end

  def price_at(date:)
    @stock_data[@stock_name][date.to_s]
  end

  def calc_percents(number:, percent: 1)
    (number / 100.0) * percent
  end

  def diff(value1, value2)
    (value1 - value2).round(1)
  end

  def rise_exceeded_within?(range, percent=1)
    price_at_day1 = price_at(date: range.begin)
    price_at_day2 = price_at(date: range.end)

    price_rise          = diff(price_at_day2, price_at_day1)
    one_percent_of_day1 = calc_percents(number: price_at_day1)

    price_rise >= one_percent_of_day1
  end
end
