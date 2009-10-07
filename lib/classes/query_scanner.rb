require 'classes/source_tree'

class QueryScanner
  attr_accessor :saved_queries, :suggested_indexes
  
  def self.parse(directories)
    self.new(directories).parse
  end
  
  def initialize(directories)
    self.source_trees = []
    
    directories.each do |directory|
      self.source_trees << SourceTree.new(directory)
    end
  end
  
  def parse
    self.scan_source!
    
    self
  end
    
  protected
  attr_accessor :source_trees
  
  def scan_source!
    self.source_trees.each do |tree|
      tree.execute_all_object_calls!
    end
        
    self.saved_queries = ActiveRecord::Base.saved_queries
    
    self.suggested_indexes = []
    self.saved_queries.each do |query|
      self.suggested_indexes += query.required_indexes unless query.required_indexes.nil?
    end

    self.suggested_indexes.uniq!    

    self.suggested_indexes.delete_if do |index|
      index.exists_in_database?
    end

    true
  end
end