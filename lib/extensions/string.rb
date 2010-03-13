require 'modules/common_regex'

class String
  include CommonRegex
  
  def parametize
    self.gsub(/[()]/,"").split(',').collect(&:strip)
  end
  
  def is_rails_view?
    ((self =~ /\.html\.(erb|haml)/ or self =~ /\.rhtml/) ? true : false)
  end
  
  def is_rails_controller?
    (self =~ /_controller\.rb$/i ? true : false)
  end
  
  def is_rails_helper?
    (self =~ /_helper\.rb$/i ? true : false)
  end
  
  def as_rails_model
    File.split(self).last.gsub('.rb','').camelize
  end
  
  def is_rails_model?
    begin
      self.as_rails_model.constantize < ActiveRecord::Base
    rescue NameError
      false
    end
  end
end
