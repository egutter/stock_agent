require 'csv'

class StockMarket
  def initialize(file_name)
    @file_name = file_name
  end

  def data_for(stock: '*', month:, year:)
    _data = source_data.reject{|row| row[1].month != month || row[1].year != year }
    _data = source_data.reject{|row| row[0] != stock } if stock != '*'
    _data
  end

  def source_data
    @data ||= load_source_data
  end

  def load_source_data(tmp_data = [])
    csv_text = File.read(@file_name)
    csv      = CSV.parse(csv_text, :headers => true)
    csv.map{|row| [row[0], Date.parse(row[1]), row[2].to_f] }
  end
end
