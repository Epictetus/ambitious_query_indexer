require 'modules/common_regex'
require 'modules/object_uniq'

class ObjectCall
  include CommonRegex
  include ObjectUniq
  
  attr_accessor :object, :method
  attr_writer   :params
  
  def initialize(opts = {})
    self.object = opts[:object]
    self.method = opts[:method]
    
    # Params is an comma-separated string of the variable names passed to this method
    self.params = opts[:params].parametize unless opts[:params].blank?
  end
  
  def derive_setter_within_source_file(source_file)
    setter_expression = /#{self.object} ?= (#{common_regex(:constant)}+)\.(#{common_regex(:method)})(\(#{common_regex(:params)}+\))?$/

    scan_results = source_file.code.scan(setter_expression)
    
    return if scan_results.blank?
    
    setters = []
    
    scan_results.each do |scan_result|
      next unless scan_result[0].is_rails_model?
      setters << ObjectCall.new(:object => scan_result[0], :method => scan_result[1], :params => scan_result[2])
    end
    
    setters
  end

  def execute!
    begin
      # in a begin/rescue because the potential for this to go wrong south of here is currently quite large.
      if self.params.blank?
        self.object.constantize.send(self.method.to_sym)
      else
        # bypass validations somehow?
        self.object.constantize.send(self.method.to_sym, *self.faked_params)
      end
    rescue
      RAILS_DEFAULT_LOGGER.debug(".... [AQI]: Calling #{self.object}.#{self.method}(#{self.faked_params.inspect}) (from #{self.params.inspect}) failed")
      nil
    end
  end
  
  def params
    # Return blank array if @params is blank.
    return @params unless @params.blank?
    return Array.new
  end

  # To implement ObjectUniq
  def identifier
    "#{self.object} - #{self.method} - #{self.params.join(',')}"
  end
  
  protected
  def faked_params
    faked_params = []
    
    # TODO: Tidy up this messy method
    
    self.params.each do |param|
      if param =~ /\[\d/
        # Looks like an array
        faked_params << []
      elsif param =~ /\[\:[\w\d]*_?id/ or param =~ /^\d+$/
        # looks like an id or just a number
        faked_params << 1
      elsif param =~ /\[[:\w\d]+/
        # looks like a hash
        faked_params << {}
      elsif param =~ /^:([\w\d]+)$/
        # looks like a symbol; pass straight through
        faked_params << $1.to_sym
      else
        # couldn't spot; most likely a string
        faked_params << 'nil'
      end
    end
    
    faked_params
  end
end