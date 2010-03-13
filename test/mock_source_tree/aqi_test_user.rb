class AqiTestUser < ActiveRecord::Base
  has_many :aqi_test_articles
end