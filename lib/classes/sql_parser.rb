require 'rubygems'
require 'smulti'

require 'classes/table_index'
require 'modules/common_regex'

class SQLParser
  include CommonRegex
  
  def initialize
    self.scope_content = {}
    
    smulti :parse, /(#{self.sql_statements.to_regex_alternates})/ do |match, remainder|
      set_current_scope(match)
      parse remainder
    end
    
    smulti :parse, /./ do |match, remainder|
      append_to_current_scope(match)
      parse remainder
    end
    
    smulti :parse, /$/ do
      # Nothing
    end
  end
  
  def indexes_for_scope(scope)
    contents = fetch_for_scope(scope)
    return if not contents

    indexes = []
        
    contents.gsub!(/`/,'')
    contents.split(/#{common_regex(:sql_conjunctions)}/).each do |clause|
      scan = clause.match(/([\w\d]+)\.([\w\d]+)/)
      next if scan.blank?
    
      indexes << TableIndex.new(:table => scan.captures[0], :fields => scan.captures[1])
    end
        
    indexes.uniq
  end
  
  # This doesn't need to be part of the public API; apart from it's used to test the parsing.
  def fetch_for_scope(scope)
    self.scope_content[scope]
  end
  
  protected
  attr_accessor :current_scope, :scope_content
  
  def set_current_scope(scope)
    self.current_scope = scope.to_scope_name
  end
  
  def append_to_current_scope(content)
    return if not self.current_scope

    if not self.scope_content.has_key?(self.current_scope)
      self.scope_content[self.current_scope] = '' 
    end
    
    self.scope_content[self.current_scope] << content
  end
  
  def sql_statements
    ['SELECT', 'FROM', 'WHERE', 'GROUP BY', 'ORDER BY', 'LIMIT', 'PROCEDURE', 'INTO', 'FOR UPDATE', 'LOCK IN SHARE MODE']
  end
end

class Array
  def to_regex_alternates
    self.join('|').gsub(/ /,'\s')
  end
end

class String
  def to_scope_name
    self.gsub(/ /, '_').downcase.to_sym
  end
end