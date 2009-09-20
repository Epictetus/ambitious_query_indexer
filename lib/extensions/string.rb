require 'modules/common_regex'

class String
  include CommonRegex
  
  def parametize
    self.gsub(/[()]/,"").split(',').collect(&:strip)
  end
  
  def is_rails_controller?
    self =~ /_controller\.rb$/i
  end
  
  def is_rails_helper?
    self =~ /_helper\.rb$/i
  end
  
  def is_rails_model?
    begin
      constant = self.constantize
      constant.ancestors.include?(ActiveRecord::Base)
    rescue NameError
      false
    end
  end
end
