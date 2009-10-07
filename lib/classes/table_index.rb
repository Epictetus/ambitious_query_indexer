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
    connection = ActiveRecord::Base.connection
    
    existing_indexes = connection.indexes(self.table).collect do |index|
      index.columns.sort
    end
    
    existing_indexes << Array(get_table_primary_key)
        
    existing_indexes.include?(self.fields.sort)
  end
  
  protected
  def get_table_primary_key
    connection = ActiveRecord::Base.connection
    
    if connection.respond_to?(:primary_key)
      # This method introduced in ActiveRecord 2.3.4
      connection.primary_key(self.table)
    elsif connection.respond_to?(:pk_and_sequence)
      pk_and_sequence = connection.pk_and_sequence_for(self.table)
      pk_and_sequence && pk_and_sequence.first
    else
      # Broad assumption!
      'id'
    end
  end
end
