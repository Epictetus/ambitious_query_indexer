require 'test_helper'
require File.expand_path(File.dirname(__FILE__) + "/db/schema_loader")

Dir[File.dirname(__FILE__) + "/mock_source_tree/*.rb"].each do |file|
  require file
end