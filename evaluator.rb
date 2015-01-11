class Evaluator
  def self.run
    start_date = Date.parse('2014-04-01')
    end_date   = Date.parse('2014-04-30')

    agent1 = StockAgent.new(['YPF', 'TS', 'GGAL'])
    agent2 = StockAgent.new(['YPF', 'TS', 'GGAL'])

    (start_date..end_date).reject{|date| date.saturday? || date.sunday? }.each do |date|
      agent1.strategy1(date)
      agent2.strategy2(date)
    end

    # agent1.list_transactions
    agent2.list_transactions

    puts "agent1 cash: #{agent1.total_cash}"
    puts "agent2 cash: #{agent2.total_cash}"

    if agent1.total_cash == agent2.total_cash
      'no winner'
    elsif agent1.total_cash > agent2.total_cash
      'strategy1 wins'
    else
      'strategy2 wins'
    end
  end
end
