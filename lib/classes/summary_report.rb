require 'classes/table_index'

class SummaryReport
  def self.generate(opts = {})
    self.new(opts).generate
  end
  
  def initialize(opts = {})
    self.results = opts[:results]
  end
  
  def generate
    report = "\n"
    report << "Scan completed!\n"

    report << "Queries executed:\t#{self.results.saved_queries.size}\n"
    report << "Suggested indexes:\t#{self.results.suggested_indexes.size}\n\n"
    
    report << "The following indexes should improve your application's performance:\n"
    
    self.results.suggested_indexes.sort! { |x,y| x.table <=> y.table }
    
    self.results.suggested_indexes.each do |index|
      report << "  * On the '#{index.table}' table, index these: #{index.fields.join(', ')}\n"
    end

    report << "\n"
    
    report
  end
  
  protected
  attr_accessor :results
end