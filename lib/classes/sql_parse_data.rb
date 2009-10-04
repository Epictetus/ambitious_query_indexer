require 'classes/table_index'
require 'modules/common_regex'

class SQLParseData
  include CommonRegex
  
  def initialize
    self.scope_content = {}
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

  def append_to_scope(scope, content)
    if not self.scope_content.has_key?(scope)
      self.scope_content[scope] = '' 
    end
    
    self.scope_content[scope] << content
    self.replace_table_aliases
    
    content
  end
  
  # Public for testing
  def fetch_for_scope(scope)
    content = self.scope_content[scope]
    return if content.nil?
    return content.strip
  end
  
  # Public for testing
  def table_aliases
    return [] unless self.fetch_for_scope(:from)
    aliases = self.fetch_for_scope(:from).scan(/([\w\d]+) (?:AS )?([\w\d]+)/)    

    table_references = self.table_references.to_regex_alternates

    aliases.delete_if do |match|      
      match[0] =~ /^(#{table_references})/i or match[1] =~ /^(#{table_references})/i
    end
  end
  
  def finalise!
    self.replace_table_aliases
  end
  
  protected
  attr_accessor :scope_content

  def replace_table_aliases
    table_aliases.each do |match|
      self.scope_content.each do |scope, content|
        content.gsub!(/#{match[1].strip}\./, "#{match[0].strip}.")
      end
    end
  end

  def table_references
    %w{OJ LEFT RIGHT INNER CROSS OUTER NATURAL JOIN STRAIGHT_JOIN USE IGNORE FORCE USING ON}
  end
end