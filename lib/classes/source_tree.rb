require 'classes/source_file'
require 'find'
require 'fileutils'

class SourceTree
  attr_accessor :path

  def initialize(path)
    self.path = path
  end
  
  def files
    files = []

    Find.find(self.path) do |file|
      next if File::directory?(file)
      next unless file.is_rails_helper? or file.is_rails_controller? or file.is_rails_view? or file.is_rails_model?
      
      code = IO.readlines(file).join
      file = SourceFile.new(code, :file_name => file)
      
      files << file
    end
    
    files
  end

  def execute_all_object_calls
    self.all_object_calls.uniq.each do |call|
      call.execute!
    end    
  end
  
  def execute_all_associations
    self.all_associations.each do |association|
      association.execute!
    end
  end
    
  protected    
  def all_object_calls
    self.files.inject([]) do |acc, file|
      acc += file.object_calls
    end
  end

  def all_associations
    associations = [] 
    
    self.files.each do |file|
      associations += file.associations unless file.associations.blank?
    end
    
    associations
  end
end