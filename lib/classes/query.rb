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
      scope_indexes = self.parser.indexes_for_scope(scope)
      indexes += scope_indexes unless scope_indexes.nil?
    end
    
    return if indexes.empty?
    
    TableIndex.merge_to_one_per_table(indexes.uniq)
  end
    
  protected
  attr_accessor :parser
  
  def parse_query!
    return self.parser unless self.parser.blank?
    self.parser = SQLParser.new
    self.parser.parse(self.sql)
  end
end