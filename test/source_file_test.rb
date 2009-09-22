require 'test_helper'

require 'classes/source_file'

class SourceFileTest < ActiveSupport::TestCase  
  test 'opening and reading basic source file' do
    file = File.join(File.dirname(__FILE__), 'mock_source_tree', 'articles_controller.rb')
    code = IO.readlines(file).join
    source_file = SourceFile.new(code)
    
    assert_equal 3, source_file.object_calls.size
  end
  
  test 'Object call location on Model.method without arguments' do
    code = 'Article.new'
    source_file = SourceFile.new(code)
    
    assert_equal 1, source_file.object_calls.size
    assert_equal 'Article', source_file.object_calls.first.object
    assert_equal 'new', source_file.object_calls.first.method
    assert_equal [], source_file.object_calls.first.params
  end
  
  test 'Object call location on Model.method() [empty brackets]' do
    code = 'Article.new()'
    source_file = SourceFile.new(code)
    
    assert_equal 1, source_file.object_calls.size
    assert_equal 'Article', source_file.object_calls.first.object
    assert_equal 'new', source_file.object_calls.first.method
    assert_equal [], source_file.object_calls.first.params
  end
  
  test 'Object call location on Model.method(arg1,arg2)' do 
    code = 'Article.new(var1,var2)'
    source_file = SourceFile.new(code)
    
    assert_equal 1, source_file.object_calls.size
    assert_equal 'Article', source_file.object_calls.first.object
    assert_equal 'new', source_file.object_calls.first.method
    assert_equal ['var1','var2'], source_file.object_calls.first.params
  end
end