require 'spec_helper'
require 'pry'

describe Evaluator do
  let(:start_date) { Date.parse('2014-04-01') }
  let(:end_date)   { Date.parse('2014-04-30') }

  it 'compares strategies for april 2014' do
    agent1 = StockAgent.new(['YPF'])

    (start_date..end_date).reject{|date| date.saturday? || date.sunday? }.each do |date|
      agent1.strategy1(date)
    end

    agent1.list_transactions
  end
end
