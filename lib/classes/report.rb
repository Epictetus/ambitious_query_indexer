require 'classes/table_index'

class Report
  def initialize(opts = {})
    self.indexes = opts[:indexes]
  end
  
  def generate
    report = "The following indexes should improve your application's performance:\n"
    
    self.indexes.sort! { |x,y| x.table <=> y.table }
    
    self.indexes.each do |index|
      report << "  * On the '#{index.table}' table, index these: #{index.fields.join(', ')}\n"
    end
    
    report
  end
  
  protected
  attr_accessor :indexes
end