require 'rubygems'
require 'smulti'

require 'classes/sql_parse_data'
require 'modules/common_regex'

class SQLParser
  include CommonRegex
  
  def initialize
    smulti :parse_query, /(#{self.sql_statements.to_regex_alternates})/ do |match, remainder|
      self.set_current_scope(match)
      parse_query remainder
    end
    
    smulti :parse_query, /./ do |match, remainder|
      self.parse_data.append_to_scope(self.current_scope, match)
      parse_query remainder
    end
    
    smulti :parse_query, /$/ do
      # Nothing
    end
  end
    
  def parse(query)
    self.parse_data = SQLParseData.new
    parse_query(query)

    self.parse_data
  end

  protected
  attr_accessor :current_scope, :parse_data

  def set_current_scope(scope)
    self.current_scope = scope.to_scope_name
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