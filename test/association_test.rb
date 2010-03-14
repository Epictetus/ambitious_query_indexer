require 'test_helper'

require 'classes/association'

class AssociationTest < ActiveSupport::TestCase
  def setup
    @source_file = SourceFile.new('ffff', :file_name => 'aqi_test_article.rb')  
    @association = Association.new(:source_file => @source_file, :class_name => 'AqiTestArticle', :reflection => AqiTestArticle.reflections[:aqi_test_user])
  end
  
  test "it can create an instance of the associating class" do
    setup
    
    model_instance = @association.send(:model_instance)
    
    assert_not_nil model_instance.id
    assert_equal @association.send(:class_name), model_instance.class.to_s
  end
  
  test "it can create an instance of the associated class" do
    setup

    association_instance = @association.send(:association_instance)

    assert_not_nil association_instance.id
    assert_equal @association.send(:reflection).send(:class_name), association_instance.class.to_s
  end
  
  test "it can associate instances" do
    setup
    
    @association.send(:associate_instances)
    
    foreign_key = @association.send(:reflection).send(:association_foreign_key)
    
    # Will only work for belongs_to atm
    assert_equal @association.send(:model_instance).send(foreign_key.to_sym), @association.send(:association_instance).id
  end
end