require 'test_helper'

require 'extensions/object'

class MockObject
  attr_accessor :mockery
  
  def initialize(opts = {})
    parse_options_into_attributes(opts)
  end
end

class ObjectTest < ActiveSupport::TestCase
  test "it parses arguments in an options hash" do
    assert_equal 'Roar!', MockObject.new(:mockery => 'Roar!').mockery
  end
end
