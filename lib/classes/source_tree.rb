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
      next unless file.is_rails_helper? or file.is_rails_controller? or file.is_rails_view?

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
    
    # Can't collect as will push Array, not contents thereof
    self.files.each do |file|
      object_calls += file.object_calls      
    end
    
    object_calls
  end
  
end