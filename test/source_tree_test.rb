require 'test_helper'

require 'classes/source_tree'

class SourceTreeTest < ActiveSupport::TestCase  
  test 'SourceTree#files loads only rails-relevant files' do
    tree = SourceTree.new(File.dirname(__FILE__) + '/mock_source_tree')
    
    # The directory contains one helper, one view and one controller,
    # but also a model and a random ruby file which should be ignored
    # '.' and '..' should also be ignored

    assert_equal 3, tree.files.size
  end
end
