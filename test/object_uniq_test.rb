require 'modules/object_uniq'

class MockObject
  include ObjectUniq
  
  attr_accessor :identifier
end

class ObjectUniqTest < ActiveSupport::TestCase  
  test 'object uniq removes dupes from an array of objects' do
    a = MockObject.new
    b = MockObject.new
    c = MockObject.new
    
    a.identifier = 1
    b.identifier = 1
    c.identifier = 2
    
    array = [a, b, c]
    
    assert_not_equal  array.uniq, [a, b, c]
    assert_equal      array.uniq, [a, c]
  end
end