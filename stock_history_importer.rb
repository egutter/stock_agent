require 'csv'

class StockHistoryImporter
  def self.run(filename, hash_data={})
    csv_text = File.read(filename)
    csv      = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      hash_data["#{row[0]}_#{Date.parse(row[1])}"] = row[2].to_f
    end
    hash_data
  end
end
