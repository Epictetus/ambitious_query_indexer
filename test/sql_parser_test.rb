require 'test_helper'

require 'classes/sql_parser'

class SQLParserTest < ActiveSupport::TestCase
  def setup_parser
    query = %q{SELECT * FROM users WHERE users.name = 'Sam' GROUP BY users.name ORDER BY users.id, users.name}
    
    parser = SQLParser.new
    parser.parse(query)
    
    parser
  end
  
  test "Array#to_regex_alternates" do 
    assert_equal 'hello|goodbye', ['hello', 'goodbye'].to_regex_alternates
  end
  
  test "String#to_scope_name" do
    assert_equal :order_by, 'ORDER BY'.to_scope_name
    assert_equal :select,   'SELECT'.to_scope_name
  end
  
  test "parsing pulls fields into the appropriate scopes" do
    parser = setup_parser
    
    assert_equal parser.fetch_for_scope(:select),   ' * '
    assert_equal parser.fetch_for_scope(:from),     ' users '
    assert_equal parser.fetch_for_scope(:where),    " users.name = 'Sam' "
    assert_equal parser.fetch_for_scope(:group_by), ' users.name '
    assert_equal parser.fetch_for_scope(:order_by), ' users.id, users.name'
  end
  
  test "parser isn't confused by sql syntax as parts of other strings" do
    # 'airports' contains 'or' need to check parser is looking for whole strings only
    query = %q{SELECT * FROM airports WHERE airports.name = 'Manchester'}
    parser = SQLParser.new
    parser.parse(query)
    
    assert_equal " airports.name = 'Manchester'", parser.fetch_for_scope(:where)
  end
    
  test "parser suggests correct indexes" do 
    parser = setup_parser
    
    assert_equal parser.indexes_for_scope(:where),    [TableIndex.new(:table => 'users', :fields => 'name')]
    assert_equal parser.indexes_for_scope(:group_by), [TableIndex.new(:table => 'users', :fields => 'name')]
    assert_equal parser.indexes_for_scope(:order_by), [TableIndex.new(:table => 'users', :fields => 'id'), TableIndex.new(:table => 'users', :fields => 'name')]
  end
  
  test "parser can understand joins in table references" do
    query = %q{SELECT `articles`.* FROM `articles` INNER JOIN `comments` ON `comments`.`article_id` = `articles`.`id`}
    parser = SQLParser.new
    parser.parse(query)
    
    assert_equal " `articles` INNER JOIN `comments` ON `comments`.`article_id` = `articles`.`id`", parser.fetch_for_scope(:from)
    assert_equal [TableIndex.new(:table => 'comments', :fields => 'article_id')], parser.indexes_for_scope(:from)
  end

  test "parser can understand aliased tables" do
    query = %q{SELECT a.id FROM articles AS a WHERE a.title = 'hello'}
    parser = SQLParser.new
    parser.parse(query)

    assert_equal "articles.title = 'hello'", parser.fetch_for_scope(:where).strip
    assert_equal [TableIndex.new(:table => 'articles', :fields => 'title')], parser.indexes_for_scope(:where)
  end
  
  test "parser can understand lazily-aliased tables" do
    query = %q{SELECT art.id FROM articles art WHERE art.title = 'lazy alias works!'}
    parser = SQLParser.new
    parser.parse(query)
    
    assert_equal "articles.title = 'lazy alias works!'", parser.fetch_for_scope(:where).strip
    assert_equal [TableIndex.new(:table => 'articles', :fields => 'title')], parser.indexes_for_scope(:where)    
  end
  
  test "table aliasing works with multiple aliases" do
    query = %q{SELECT a.id, c.id FROM articles a LEFT JOIN comments AS c ON c.article_id = a.id}
    parser = SQLParser.new
    parser.parse(query)
    
    assert_equal [['articles','a'], ['comments','c']], parser.table_aliases
    assert_equal ' articles.id, comments.id ', parser.fetch_for_scope(:select)
  end
  
  test "parser does not confuse lazy table aliasing with sql syntax" do
    # Otherwise known as 'test to prove previous bugs with this code remain squashed'
    
    query = %q{SELECT u.id FROM users u, articles LEFT JOIN comments ON comments.article_id = articles.id WHERE b.user_id = articles.user_id}
    parser = SQLParser.new
    parser.parse(query)
    
    assert_equal false, parser.table_aliases.include?(['articles','LEFT'])
    
    query = %q{SELECT `articles`.* FROM `articles` INNER JOIN `comments` ON `comments`.`article_id` = `articles`.`id`}
    parser = SQLParser.new
    parser.parse(query)

    assert_equal false, parser.table_aliases.include?(['articles','INNER'])
    assert_equal false, parser.table_aliases.include?(['INNER', 'JOIN'])
    
    query = %q{SELECT articles.* FROM articles JOIN comments AS c ON c.article_id = comments.id}
    parser = SQLParser.new
    parser.parse(query)
    
    assert_equal false, parser.table_aliases.include?(['articles','JOIN'])
    assert_equal [['comments','c']], parser.table_aliases
  end
end