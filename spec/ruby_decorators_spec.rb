require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RubyDecorators do
  class DummyDecorator < RubyDecorator
    def call(this)
      'I should never be called'
    end
  end

  class Hi < RubyDecorator
    def call(this, *args, &blk)
      this.call(*args, &blk).sub('hello', 'hi')
    end
  end

  class Batman < RubyDecorator
    def call(this, *args, &blk)
      this.call(*args, &blk).sub('world', 'batman')
    end
  end

  class Catwoman < RubyDecorator
    def initialize(*args)
      @args = args.any? ? args : ['catwoman']
    end

    def call(this, *args, &blk)
      this.call(*args, &blk).sub('world', @args.join(' '))
    end
  end

  class DummyClass2
    extend RubyDecorators

    +Hi
    def hi
      'hello'
    end
  end

  class DummyClass
    extend RubyDecorators

    def initialize
      @greeting = 'hello world'
    end

    def hello_world
      @greeting
    end

    +Batman
    def hello_public
      @greeting
    end

    +DummyDecorator
    def hello_void
      @greeting
    end

    def hello_untouched
      @greeting
    end

    +Batman
    def hello_with_args(arg1, arg2)
      "#{@greeting} #{arg1} #{arg2}"
    end

    +Catwoman
    def hello_catwoman
      @greeting
    end

    +Batman
    def hello_with_block(arg1, arg2, &block)
      "#{@greeting} #{arg1} #{arg2} #{block.call if block_given?}"
    end

    +Catwoman.new('super', 'catwoman')
    def hello_super_catwoman
      @greeting
    end

    +Hi
    +Batman
    def hi_batman
      @greeting
    end

    +Hi
    +Catwoman.new('super', 'catwoman')
    def hi_super_catwoman(arg1)
      "#{@greeting}#{arg1}"
    end

    protected

    +Batman
    def hello_protected
      @greeting
    end

    private

    +Batman
    def hello_private
      @greeting
    end
  end

  subject { DummyClass.new }

  it "#hello_world" do
    DummyClass2.new.hi.must_equal 'hi'
    subject.hello_world.must_equal 'hello world'
  end

  describe "a simple decorator" do
    it "clones and clears the stack" do
      arr = MiniTest::Mock.new
      arr.expect(:tap, nil)
      arr.expect(:clone, [DummyDecorator])
      arr.expect(:clear, nil)
      RubyDecorators::Stack.stub :all, arr do
        assert arr.clone == [DummyDecorator]
      end
      subject.hello_public.must_equal 'hello batman'
    end

    it "decorates a public method" do
      subject.hello_public.must_equal 'hello batman'
    end

    it "decorates a protected method" do
      subject.send(:hello_protected).must_equal 'hello batman'
      lambda { subject.hello_protected }.must_raise NoMethodError
    end

    it "decorates a private method" do
      subject.send(:hello_private).must_equal 'hello batman'
      lambda { subject.hello_private }.must_raise NoMethodError
    end

    it "decorates a method with args" do
      subject.hello_with_args('how are', 'you?').must_equal 'hello batman how are you?'
    end

    it "decorates a method with a block" do
      subject.hello_with_block('how are', 'you') { 'man?' }.must_equal 'hello batman how are you man?'
    end

    it "ignores undecorated methods" do
      subject.hello_untouched.must_equal 'hello world'
    end
  end

  describe "a decorator with args" do
    it "decorates without any decorator args" do
      subject.hello_catwoman.must_equal 'hello catwoman'
    end

    it "decorate a simple method" do
      subject.hello_super_catwoman.must_equal 'hello super catwoman'
    end
  end

  describe "multiple decorators" do
    it "decorates a simple method" do
      subject.hi_batman.must_equal 'hi batman'
    end

    it "decorates a method with args" do
      subject.hi_super_catwoman('!').must_equal 'hi super catwoman!'
    end
  end
end
