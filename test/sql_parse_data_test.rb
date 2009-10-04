require 'test_helper'

require 'classes/sql_parse_data'

class SQLParseDataTest < ActiveSupport::TestCase
  test "adding and fetching with a blank scope" do 
    parse_data = SQLParseData.new
    assert_nil parse_data.fetch_for_scope(:from)
    
    append_string = 'articles AS a'
    parse_data.append_to_scope(:from, append_string)
    assert_equal append_string, parse_data.fetch_for_scope(:from)    
  end
  
  test "appending and fetching with an existing scope" do
    parse_data = SQLParseData.new

    append_string = 'articles AS a'
    parse_data.append_to_scope(:from, append_string)
    assert_equal append_string, parse_data.fetch_for_scope(:from)    

    parse_data.append_to_scope(:from, append_string)
    assert_equal append_string * 2, parse_data.fetch_for_scope(:from)     
  end

  test "can understand explicitly-aliased tables" do
    parse_data = SQLParseData.new
    parse_data.append_to_scope(:from, %q{articles AS a})
    parse_data.append_to_scope(:where, %q{a.title = 'hello'})
    
    assert_equal "articles.title = 'hello'", parse_data.fetch_for_scope(:where)
  end
  
  test "can understand lazily-aliased tables" do
    parse_data = SQLParseData.new
    
    parse_data.append_to_scope(:from, %q{articles art})
    parse_data.append_to_scope(:where, %q{art.title = 'lazy alias works!'})

    assert_equal "articles.title = 'lazy alias works!'", parse_data.fetch_for_scope(:where)
  end
    
  test "table aliasing works with multiple aliases" do
    parse_data = SQLParseData.new
    parse_data.append_to_scope(:select, %q{a.id, c.id})
    parse_data.append_to_scope(:from, %q{articles a LEFT JOIN comments AS c ON c.article_id = a.id})
    
    assert_equal [['articles','a'], ['comments','c']], parse_data.table_aliases
    assert_equal 'articles.id, comments.id', parse_data.fetch_for_scope(:select)
  end
  
  test "does not confuse lazy table aliasing with sql syntax" do
    # Otherwise known as 'test to prove previous bugs with this code remain squashed'
    
    parse_data = SQLParseData.new
    parse_data.append_to_scope(:from, %q{users u, articles LEFT JOIN comments ON comments.article_id = articles.id})
    assert_equal false, parse_data.table_aliases.include?(['articles','LEFT'])

    parse_data = SQLParseData.new
    parse_data.append_to_scope(:from, %q{FROM `articles` INNER JOIN `comments` ON `comments`.`article_id` = `articles`.`id`})    
    assert_equal false, parse_data.table_aliases.include?(['articles','INNER'])
    assert_equal false, parse_data.table_aliases.include?(['INNER', 'JOIN'])
    
    parse_data = SQLParseData.new
    parse_data.append_to_scope(:from, %q{articles JOIN comments AS c ON c.article_id = comments.id})    
    assert_equal false, parse_data.table_aliases.include?(['articles','JOIN'])
    assert_equal [['comments','c']], parse_data.table_aliases
  end
end