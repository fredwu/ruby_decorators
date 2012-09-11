class RubyDecorator
  def self.+@
    RubyDecorators::Stack.decorators << self
  end

  def +@
    RubyDecorators::Stack.decorators << self
  end
end
