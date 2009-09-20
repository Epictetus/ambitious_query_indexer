require 'classes/source_tree'
require 'classes/report'

require 'extensions/string'
require 'extensions/active_record'

class AmbitiousQueryIndexer
  attr_accessor :source_trees
  
  def initialize(directories)
    self.source_trees = []
    self.required_indexes = []
    
    directories.each do |directory|
      self.source_trees << SourceTree.new(directory)
    end
  end
    
  def analyse
    self.scan_for_missing_indexes!
    
    report = Report.new(:indexes => self.required_indexes)
    puts report.generate
  end
  
  protected
  attr_accessor :required_indexes
  
  def scan_for_missing_indexes!
    self.source_trees.each do |tree|
      tree.execute_all_object_calls!
    end
    
    ActiveRecord::Base.saved_queries.each do |query|
      self.required_indexes += query.required_indexes unless query.required_indexes.nil?
    end    
    
    self.required_indexes.delete_if do |index|
      index.exists_in_database?
    end
        
    self.required_indexes.uniq!
  end
end