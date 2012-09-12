# Ruby Decorators

#### Ruby method decorators inspired by Python.

I wrote this as a small practice for some ruby meta-programming fun.

There are also these other two implementations:

- Yehuda Katz's [Ruby Decorators](https://github.com/wycats/ruby_decorators)
- Michael Fairley's [Method Decorators](https://github.com/michaelfairley/method_decorators)

## Installation

Add this line to your application's Gemfile:

    gem 'ruby_decorators'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby_decorators

## Usage

```ruby
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

class World
  extend RubyDecorators

  def initialize
    @greeting = 'hello world'
  end

  def hello_world
    @greeting
  end

  +Batman
  def hello_batman
    @greeting
  end

  +Catwoman
  def hello_catwoman
    @greeting
  end

  +Catwoman.new('super', 'catwoman')
  def hello_super_catwoman
    @greeting
  end
end

world = World.new

world.hello_world          # => "hello world"
world.hello_batman         # => "hello batman"
world.hello_catwoman       # => "hello catwoman"
world.hello_super_catwoman # => "hello super catwoman"
```

## License

Copyright (c) 2012 [Fred Wu](http://fredwu.me/)

Licensed under the [MIT license](http://fredwu.mit-license.org/).
