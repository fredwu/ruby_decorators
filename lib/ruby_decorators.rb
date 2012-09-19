require "ruby_decorators/version"
require "ruby_decorator"

module RubyDecorators
  class Stack
    def self.all
      @all ||= []
    end
  end

  def method_added(method_name)
    super

    @methods    ||= {}
    @decorators ||= {}

    return if RubyDecorators::Stack.all.empty?

    @methods[method_name]    = instance_method(method_name)

    RubyDecorators::Stack.all.tap do |a|
      @decorators[method_name] = a.clone
    end.clear

    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      #{method_visibility_for(method_name)}
      def #{method_name}(*args, &blk)
        decorators = self.class.instance_variable_get(:@decorators)[:#{method_name}]
        method     = self.class.instance_variable_get(:@methods)[:#{method_name}]

        decorators.inject(method.bind(self)) do |method, decorator|
          decorator = decorator.new if decorator.respond_to?(:new)
          lambda { |*a, &b| decorator.call(method, *a, &b) }
        end.call(*args, &blk)
      end
    RUBY_EVAL
  end

  private

  def method_visibility_for(method_name)
    if private_method_defined?(method_name)
      :private
    elsif protected_method_defined?(method_name)
      :protected
    else
      :public
    end
  end
end
