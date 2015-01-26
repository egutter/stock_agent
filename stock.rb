class Stock
  def initialize(stock_history, name)
    @data = stock_history
    @name = name
  end

  def name; @name; end
  def data; @data; end

  def price_at(date)
    data[name][date.to_s]
  end

  def price_change_for_day(current_day:, ref_day:nil)
    price_at_current_day = price_at(current_day)
    price_at_ref_day     = price_at(ref_day || previous_day(current_day))

    return if price_at_current_day.nil? || price_at_ref_day.nil?

    (((price_at_current_day - price_at_ref_day) / price_at_ref_day) * 100).round(2)
  end

  def average_price_until(date)
    return unless date.is_a?(Date)

    price_list     = business_days_of_month(date).reject{|bday| bday > date.to_s }
      .map{ |bday| price_at(bday) }
    price_size     = price_list.size
    price_list_sum = price_list.inject(0.0) { |sum, el| sum + el }

    return if !price_size || price_size == 0

    (price_list_sum / price_size).round(3)
  end

  def previous_day(date)
    return if date.day == 1
    prev_day = date - 1
    price_at(prev_day).nil? ? previous_day(prev_day) : prev_day
  end

  def business_days_of_month(date)
    data[name].reject{ |k,v|
      v.nil? || !k.to_s.match(/#{date.year}-#{date.month.to_s.rjust(2, "0")}-\d{2}/)
    }.keys.sort
  end

  def first_business_day_of_month(date)
    business_days_of_month(date).first
  end

  def last_business_day_of_month(date)
    business_days_of_month(date).last
  end
end
