require 'test_helper'

require 'extensions/active_record'

class ActiveRecordLoggerTest < ActiveSupport::TestCase
  test "ActiveRecord is responding to saved_queries" do 
    assert_equal ActiveRecord::Base.saved_queries.class, Array  
  end
  
  test "ActiveRecord is logging queries" do
    query = "SELECT 1"
    
    ActiveRecord::Base.connection.execute(query, 'Test Query')
    assert_equal ActiveRecord::Base.saved_queries.last.sql, query
  end
  
  test "ActiveRecord is not logging queries with no 'name'" do
    query = "SELECT 2"

    ActiveRecord::Base.connection.execute(query)
    assert_not_equal ActiveRecord::Base.saved_queries.last.sql, query    
  end
end
