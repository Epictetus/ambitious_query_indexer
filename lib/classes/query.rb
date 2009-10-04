require 'classes/sql_parser'
require 'classes/table_index'

class Query
  attr_accessor :sql, :name
  
  def initialize(opts = {})
    self.sql, self.name = opts[:sql], opts[:name]
  end
  
  def required_indexes
    # MySQL can only use one index so will always return one index.
    self.parse_query!
    
    indexes = []
    
    [:from, :where, :group_by, :order_by].each do |scope|
      scope_indexes = self.parse_data.indexes_for_scope(scope)
      indexes += scope_indexes unless scope_indexes.nil?
    end
    
    return if indexes.empty?
    
    TableIndex.merge_to_one_per_table(indexes.uniq)
  end
    
  protected
  attr_accessor :parse_data
  
  def parse_query!
    return self.parse_data unless self.parse_data.blank?
    self.parse_data = SQLParser.new.parse(self.sql)
  end
end