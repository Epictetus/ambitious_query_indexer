require 'test_helper'

require 'classes/object_call'

class ObjectCallTest < ActiveSupport::TestCase
  test "params returns blank array if getter returns nil" do
    object_call = ObjectCall.new()

    assert_equal [], object_call.params
  end
  
  test "execution works with no params required" do
    object_call = ObjectCall.new(:object => 'Article', :method => 'create')
    assert_equal 'winner', object_call.execute!
  end
  
  test "execution works with mocked params" do
    object_call = ObjectCall.new(:object => 'Article', :method => 'find_with_some_args', :params => 'var1, var2')
    assert_equal 'winner, winner', object_call.execute!
  end
  
  test "execution works with more exotic mocked params" do
    object_call = ObjectCall.new(:object => 'Article', :method => 'find_with_more_args', :params => 'params[:hello], params[:id], params[:hello_id], 1, hello[2], :all')
    
    args = object_call.execute!
    
    assert_equal Hash,    args[0].class
    assert_equal Fixnum,  args[1].class
    assert_equal Fixnum,  args[2].class
    assert_equal Fixnum,  args[3].class
    assert_equal Array,   args[4].class
    assert_equal Symbol,  args[5].class
  end
end