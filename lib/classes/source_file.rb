require 'classes/object_call'
require 'modules/common_regex'

class SourceFile
  include CommonRegex
  
  attr_accessor :code
  
  def initialize(code)
    self.code = code
  end
  
  def object_calls
    object_calls = []

    finder_expression = /(#{common_regex(:variable)}+)\.(#{common_regex(:method)}+)(\(#{common_regex(:params)}+\))?/
    
    self.code.scan(finder_expression).each do |call|
      object, method, params = call[0], call[1], call[2]

      object_call = ObjectCall.new(self, :object => object, :method => method, :params => params)
      
      object_calls.push << object_call
    end
    
    object_calls
  end  
end