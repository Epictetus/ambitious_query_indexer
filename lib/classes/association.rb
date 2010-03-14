class Association
  def initialize(opts = {})
    parse_options_into_attributes(opts)
  end
    
  def execute!
    self.associate_instances
    self.run
  end
  
  protected
  attr_accessor :reflection, :class_name
  
  def run
    if self.reflection.belongs_to?
      res = self.model_instance.send(self.reflection.name.to_sym)
    end
  end
  
  def model_instance
    @model_instance ||= generate_instance(self.class_name)
  end
  
  def association_instance
    @association_instance ||= generate_instance(self.reflection.class_name)
  end  
  
  def associate_instances
    if self.reflection.belongs_to?
      self.model_instance.send("#{self.reflection.primary_key_name}=".to_sym, self.association_instance.id)
      self.model_instance.save_with_validation(false)
      self.model_instance.reload
    end
  end
  
  def generate_instance(model_name)
    model = model_name.constantize
    
    instance = model.new
    instance.save_with_validation(false)
    
    instance
  end
end