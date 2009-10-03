require 'rubygems'
require 'smulti'

require 'classes/table_index'
require 'modules/common_regex'

class SQLParser
  include CommonRegex
  
  def initialize
    self.scope_content = {}

    smulti :parse_query, /(#{self.sql_statements.to_regex_alternates})/ do |match, remainder|
      set_current_scope(match)
      parse_query remainder
    end
    
    smulti :parse_query, /./ do |match, remainder|
      append_to_current_scope(match)
      parse_query remainder
    end
    
    smulti :parse_query, /$/ do
      # Nothing
    end
  end
    
  def parse(query)
    parse_query(query)
    replace_table_aliases!
  end
    
  def indexes_for_scope(scope)
    contents = fetch_for_scope(scope)
    return if not contents

    indexes = []
        
    contents.gsub!(/`/,'')
    
    contents.split(/#{common_regex(:sql_conjunctions)}/i).each do |clause|
      scan = clause.match(/([\w\d]+)\.([\w\d]+)\s?/)
      next if scan.blank?
    
      indexes << TableIndex.new(:table => scan.captures[0], :fields => scan.captures[1])
    end
    
    indexes.uniq
  end
  
  # Public for testing
  def fetch_for_scope(scope)
    self.scope_content[scope]
  end
  
  # Public for testing
  def table_aliases
    return [] unless fetch_for_scope(:from)
    aliases = fetch_for_scope(:from).scan(/([\w\d]+) (?:AS )?([\w\d]+)/)    

    table_references = self.table_references.to_regex_alternates

    aliases.delete_if do |match|      
      match[0].strip =~ /^(#{table_references})/i or match[1].strip =~ /^(#{table_references})/i
    end
  end
  
  protected
  attr_accessor :current_scope, :scope_content

  def sql_statements
    ['SELECT', 'FROM', 'WHERE', 'GROUP BY', 'ORDER BY', 'LIMIT', 'PROCEDURE', 'INTO', 'FOR UPDATE', 'LOCK IN SHARE MODE']
  end
  
  def table_references
    %w{OJ LEFT RIGHT INNER CROSS OUTER NATURAL JOIN STRAIGHT_JOIN USE IGNORE FORCE USING ON}
  end
  
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
  
  def replace_table_aliases!
    table_aliases.each do |match|
      self.scope_content.each do |scope, content|
        content.gsub!(/#{match[1].strip}\./, "#{match[0].strip}.")
      end
    end
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