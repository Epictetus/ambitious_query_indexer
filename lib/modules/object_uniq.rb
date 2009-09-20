module ObjectUniq
  def identifier
    self.object_id
  end

  def hash
    self.identifier.hash
  end

  def eql?(comparee)
    self == comparee
  end

  def ==(comparee)
    self.identifier == comparee.identifier
  end
end