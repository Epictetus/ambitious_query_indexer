require 'test_helper'

require 'classes/table_index'

class TableIndexTest < ActiveSupport::TestCase
  test "class method to merge multiple index requirements on a single table" do
    index_a = TableIndex.new(:table => 'users', :fields => 'name')
    index_b = TableIndex.new(:table => 'users', :fields => 'date_of_birth')
    
    expected_index = TableIndex.new(:table => 'users', :fields => ['name','date_of_birth'])
    merged_index = TableIndex.merge_to_one_per_table([index_a, index_b])
    
    assert_equal [expected_index], merged_index
  end
  
  test "checking existence of database index" do
    index_a = TableIndex.new(:table => 'aqi_test_articles', :fields => ['aqi_test_user_id', 'name'])
    index_b = TableIndex.new(:table => 'aqi_test_articles', :fields => ['aqi_test_user_id'])
        
    assert_equal true,  index_a.exists_in_database?
    assert_equal false, index_b.exists_in_database?
  end
  
  test "order of TableIndex#fields does not affect TableIndex#exists_in_database?" do
    index_a = TableIndex.new(:table => 'aqi_test_articles', :fields => ['name', 'aqi_test_user_id'])
    assert_equal true, index_a.exists_in_database?
  end
  
  test "TableIndex includes primary keys in index list" do
    index_a = TableIndex.new(:table => 'aqi_test_articles', :fields => ['id'])
    assert_equal true, index_a.exists_in_database?
  end
end