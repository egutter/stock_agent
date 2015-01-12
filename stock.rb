class Stock
  def initialize(stock_name, filename = 'stock_history.csv')
    @stock_name = stock_name
    @stock_data ||= StockHistoryImporter.run(filename)
  end

  def self.maximum_purchaseable_amount(cash_limit, price)
    return 0 if !cash_limit.is_a?(Numeric) || !price.is_a?(Numeric) || price <= 0 || cash_limit <= 0
    (cash_limit / price).to_i
  end

  def name
    @stock_name
  end

  def price_at(date)
    return if !@stock_data || !@stock_data[@stock_name]
    @stock_data[@stock_name][date.to_s]
  end

  def price_change_for_day(current_day:, ref_day:nil)
    price_at_current_day = price_at(current_day)
    price_at_ref_day     = price_at(ref_day || previous_day(current_day))

    return if price_at_current_day.nil? || price_at_ref_day.nil?

    (((price_at_current_day - price_at_ref_day) / price_at_ref_day) * 100).round(2)
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
