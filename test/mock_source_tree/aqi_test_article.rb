class AqiTestArticle < ActiveRecord::Base
  belongs_to :aqi_test_user
  
  def self.create
    'winner'
  end
  
  def self.find_with_some_args(var1, var2)
    'winner, winner'
  end
  
  def self.find_with_more_args(*args)
    args
  end
end