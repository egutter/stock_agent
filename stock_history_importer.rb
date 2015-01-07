require 'csv'

class StockHistoryImporter
  def self.run(filename)
    csv_text = File.read(filename)
    csv      = CSV.parse(csv_text, :headers => true)
    csv.map{|row| [row[0], Date.parse(row[1]), row[2].to_f] }
  end
end
