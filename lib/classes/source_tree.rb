require 'classes/source_file'
require 'find'

class SourceTree
  attr_accessor :path

  def initialize(path)
    self.path = path
  end
  
  def files
    files = []

    Find.find(self.path) do |file|
      next unless file.is_rails_helper? or file.is_rails_controller?

      code = IO.readlines(file).join
      file = SourceFile.new(code)
      
      files << file
    end
    
    files
  end

  def execute_all_object_calls!
    self.all_object_calls.uniq.each do |call|
      call.execute!
    end    
  end
  
  protected  
  def all_object_calls
    object_calls = []
    
    self.files.each do |file|
      file.object_calls.each do |call|
        object_calls << call
      end
    end
    
    object_calls
  end
end