require 'test_helper'

require 'classes/query'
require 'classes/table_index'

class QueryTest < ActiveSupport::TestCase
  test "initializes correctly" do 
    sql = 'select 1'
    name = 'test query'
    
    assert_equal sql,   Query.new(:sql => sql).sql
    assert_equal name,  Query.new(:name => name).name
  end
  
  test "will return indexes for queries" do
    query_a = Query.new(:sql => %q{SELECT * FROM articles WHERE `articles`.`id` = 1})
    query_a_expected_index = TableIndex.new(:table => 'articles', :fields => ['id'])
    assert_equal [query_a_expected_index], query_a.required_indexes
    
    query_b = Query.new(:sql => %q{SELECT * FROM articles GROUP BY articles.name ORDER BY articles.id ASC})
    query_b_expected_index = TableIndex.new(:table => 'articles', :fields => ['name', 'id'])
    assert_equal [query_b_expected_index], query_b.required_indexes
  end
end