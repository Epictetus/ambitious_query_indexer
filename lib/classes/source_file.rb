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

      object_call = ObjectCall.new(:object => object, :method => method, :params => params)
      
      if not object.is_rails_model?
        object_setters = object_call.derive_setter_within_source_file(self)
        if not object_setters.blank?
          object_calls += object_setters
        end
      else
        object_calls.push << object_call
      end
    end
    
    object_calls
  end  
end