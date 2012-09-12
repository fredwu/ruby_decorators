class RubyDecorator
  def self.+@
    RubyDecorators::Stack.all << self
  end

  def +@
    RubyDecorators::Stack.all << self
  end
end
