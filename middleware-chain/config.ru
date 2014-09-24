require 'rack'

class MyApp
  def initialize
    puts "MyApp Initialized"
  end

  def call(env)
    puts "MyApp Called"
    [200, {'Content-Type' => 'text/html'}, ["MyApp Was Here!<br />"]]
  end
end

class SomeMiddleStuff
  def initialize(app)
    puts "SomeMiddleStuff Initialized"
    @app = app
  end

  def call(env)
    puts "SomeMiddleStuff Called"
    status, headers, response = @app.call(env)
    body = response.first + "SomeMiddleStuff Was Here!<br />"
    [status, headers, [body]]
  end
end

class AnotherThing
  def initialize(app)
    puts "AnotherThing Initialized"
    @app = app
  end

  def call(env)
    puts "AnotherThing Called"
    status, headers, response = @app.call(env)
    body = response.first + "AnotherThing Was Here!<br />"
    [status, headers,[body]]
  end
end

use AnotherThing
use SomeMiddleStuff
run MyApp.new