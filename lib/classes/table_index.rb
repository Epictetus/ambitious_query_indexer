require 'modules/object_uniq'

class TableIndex
  include ObjectUniq
  
  attr_accessor :table, :fields
  
  def initialize(opts = {})
    self.table  = opts[:table]
    self.fields = opts[:fields]
  end

  # To implement uniq
  def identifier
    "#{self.table} - #{self.fields.to_s}"
  end
  
  def self.merge_to_one_per_table(indexes)
    tables = {}
    
    indexes.each do |index|
      tables[index.table] = TableIndex.new(:table => index.table, :fields => []) if not tables[index.table]
      tables[index.table].fields += Array(index.fields)      
    end
    
    return tables.values
  end
  
  def exists_in_database?
    existing_indexes = []
    
    ActiveRecord::Base.connection.indexes(self.table).each do |index|
      existing_indexes << index.columns.sort
    end
    
    existing_indexes << Array(ActiveRecord::Base.connection.primary_key(self.table))
        
    existing_indexes.include?(self.fields.sort)
  end
end
