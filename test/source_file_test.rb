require 'test_helper'

require 'classes/source_file'

class SourceFileTest < ActiveSupport::TestCase
  def setup_source_file
    file = File.join(File.dirname(__FILE__), 'mock_source_tree', 'articles_controller.rb')
    code = IO.readlines(file).join
    SourceFile.new(code)
  end
  
  test 'test' do
    source_file = setup_source_file
    
    assert_equal 3, source_file.object_calls.size
  end
end