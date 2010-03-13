class Object
  def parse_options_into_attributes(opts)
    opts.each do |index, value|
      next unless self.respond_to?("#{index}=")
      self.send("#{index}=".to_sym, value)
    end
  end
end