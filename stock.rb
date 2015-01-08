class Stock
  def initialize(stock_name, filename = 'stock_history.csv')
    @stock_name = stock_name
    @stock_data ||= StockHistoryImporter.run(filename)
  end

  def price_at(date)
    @stock_data[@stock_name][date.to_s]
  end

  def calc_percents(number:, percent: 1)
    (number / 100.0) * percent
  end

  def diff(value1, value2)
    (value1 - value2).round(2)
  end

  def price_change_for_day(day1)
    price_at_day1 = price_at(previous_day(day1))
    price_at_day2 = price_at(day1)

    return if price_at_day1.nil? || price_at_day2.nil?

    diff(price_at_day2, price_at_day1) / calc_percents(number: price_at_day1, percent: 1)
  end

  def previous_day(date)
    return if date.day == 1
    prev_day = date - 1

    price_at(prev_day).nil? ? previous_day(prev_day) : prev_day
  end
end
