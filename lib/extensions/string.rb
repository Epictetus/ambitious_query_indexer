require 'modules/common_regex'

class String
  include CommonRegex
  
  def parametize
    self.gsub(/[()]/,"").split(',').collect(&:strip)
  end
  
  def is_rails_view?
    self =~ /\.html\.(erb|haml)/ or self =~ /\.rhtml/
  end
  
  def is_rails_controller?
    self =~ /_controller\.rb$/i
  end
  
  def is_rails_helper?
    self =~ /_helper\.rb$/i
  end
  
  def is_rails_model?
    begin
      self.constantize < ActiveRecord::Base
    rescue NameError
      false
    end
  end
end
