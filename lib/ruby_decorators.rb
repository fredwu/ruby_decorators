require "ruby_decorators/version"
require "ruby_decorator"
require "ruby_decorators/stack"

module RubyDecorators
  def method_added(method_name)
    @__decorated_methods ||= []

    return if RubyDecorators::Stack.decorators.empty?  ||
              method_name.to_s =~ /__undecorated_/     ||
              @__decorated_methods.include?(method_name)

    current_decorator = RubyDecorators::Stack.decorators.pop
    method_visibility = detect_method_visibility(method_name)

    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      alias_method :__undecorated_#{method_name}, :#{method_name}

      @__decorators ||= {}
      @__decorators["#{method_name}"] = current_decorator

      #{method_visibility}
      def #{method_name}(*args, &blk)
        decorator = #{current_decorator}.new
        decorator ||= self.class.instance_variable_get(:@__decorators)["#{method_name}"]

        if args.any?
          decorator.call(self.send :__undecorated_#{method_name}, *args, &blk)
        else
          decorator.call(self.send :__undecorated_#{method_name}, &blk)
        end
      end
    RUBY_EVAL

    @__decorated_methods << method_name
  end

  private

  def detect_method_visibility(method_name)
    if private_method_defined?(method_name)
      :private
    elsif protected_method_defined?(method_name)
      :protected
    else
      :public
    end
  end
end
