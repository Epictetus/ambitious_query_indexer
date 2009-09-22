module CommonRegex
  @@regex = {
    :constant         => '(?:[A-Z]+[a-z]*)',
    :method           => '[\w\d?!]',
    :variable         => '[@\w]',
    :params           => '[\w\d\s,.?!\[\]:]',
    :sql_conjunctions => 'AND\s|OR\s|\|\|\s|&&\s|,',
  }

  def common_regex(identifier)
    return @@regex[identifier.to_sym]
  end
end