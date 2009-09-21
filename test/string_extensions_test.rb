require 'test_helper'

require 'extensions/string'

class MockModel < ActiveRecord::Base
end

class StringTest < ActiveSupport::TestCase
  # Where testing for assert_equal [N], this is the position at which
  # the matching pattern appears - would prefer this to be true/false
  
  
  test "parametize gives a list of parameters" do 
    assert_equal ['1', '2', '3'], '(1,2,3)'.parametize
  end
  
  test "parametize strips whitespace" do 
    assert_equal ['1', '2', '3'], '(1  , 2,3)'.parametize
  end
  
  test "rails artefact sensing for views" do
    assert_equal 4,   'show.rhtml'.is_rails_view?
    assert_equal 4,   'show.html.erb'.is_rails_view?
    assert_equal 4,   'show.html.haml'.is_rails_view?
    assert_equal nil, 'show.html'.is_rails_view?
    assert_equal nil, 'string_helper.rb'.is_rails_view?
    assert_equal nil, 'string_controller.rb'.is_rails_view?
  end
  
  test "rails artefact sensing for helpers" do 
    assert_equal  6, 'string_helper.rb'.is_rails_helper?
    assert_equal  nil, 'string.rb'.is_rails_helper?
  end
  
  test "rails artefact sensing for controllers" do
    assert_equal  6, 'string_controller.rb'.is_rails_controller?
    assert_equal  nil, 'string.rb'.is_rails_controller?
  end
    
  test "rails artefact sensing for models" do
    assert_equal  true, 'MockModel'.is_rails_model?
    assert_equal  false, 'NoModel'.is_rails_model?  
  end
end
