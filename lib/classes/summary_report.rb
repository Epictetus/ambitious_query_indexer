require 'classes/table_index'

class SummaryReport
  def self.view(opts = {})
    self.new(opts).view
  end
  
  def initialize(opts = {})
    self.results = opts[:results]
    self.report = []
  end

  def title(text)
    line
    self.report << text
    underline(text)
    line
  end
  
  def underline(text)
    underline = ''
    
    text.length.times do
      underline << '-'
    end
    
    self.report << underline
  end
  
  def line(text = '')
    self.report << text
  end
  
  def migration(indexes)
    create_commands = []
    remove_commands = []
    
    indexes.each do |index|
      fields = index.fields.collect { |field| ":#{field}" }
      
      create_commands << "add_index :#{index.table}, [#{fields.join(', ')}]"
      remove_commands << "remove_index :#{index.table}, [#{fields.join(', ')}]"
    end
    
    migration = <<-MIGRATION
class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    #{create_commands.join("\n    ")}
  end

  def self.down
    #{remove_commands.join("\n    ")}
  end
end    
    MIGRATION
  end
  
  def generate
    title "Scan completed!"

    line "Queries executed:\t#{self.results.saved_queries.size}"
    line "Suggested indexes:\t#{self.results.suggested_indexes.size}"
    
    title "Suggested Indexes"
    
    line "The following indexes should improve your application's performance:"
    
    self.results.suggested_indexes.sort! { |x,y| x.table <=> y.table }
      
    self.results.suggested_indexes.each do |index|
      line "  * On the '#{index.table}' table, index these: #{index.fields.join(', ')}"
    end
    
    title "Migration"
    
    line "Here's a sample migration that will add the above:"
    line
    
    line self.migration(self.results.suggested_indexes)
    
    line
  end
  
  def view
    self.generate
    self.report.join("\n")
  end
  
  protected
  attr_accessor :results, :report
end