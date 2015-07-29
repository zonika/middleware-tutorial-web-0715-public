

## Using Middleware

Middleware is a way to filter a request coming into and a response leaving our application. If you think of our Rack app as a shelf in a, well, rack, you can think of middleware as something sitting on top of that shelf. In essence, we can create a chain of applications that can mess around with the response before it gets back to the user.

Let's use a really simple example. Make a new directory in the top level of this project called `hello-with-middleware`, and then `cd` into it.

1. Create the following files:
  * `config.ru`
  * `hello.rb`
  * `randomize.rb`
2. At the top of `config.ru` add the lines
  
  ```ruby
  require 'rack'
  require_relative './hello'
  require_relative './randomize'
  ```

3. In `hello.rb` define the following class:

  ```ruby
  class Hello

    def call(env)
      [200, {'Content-Type' => 'text/html'}, ["Hello, "]]
    end

  end
  ```

4. In `randomize.rb` define the following class:

  ```ruby
  class Randomize

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)
      response_body = response.first + "number #{rand(100)}"

      [status, headers, [response_body]]
    end
  end
  ```

5. Let's look at these classes one at a time, and then talk about how we'll use them in our `config.ru` file.

  First, we'll look at `Hello`. This look pretty familiar. It's a class that responds to `call` and accepts `env` as an argument. Nothing new there.

  `Randomize` looks a little weird, though. For one, it has an `initialize` method. For another, it does some weird stuff in the `call` method. Let's look at `initialize` first.

  `initialize` accepts one argument, which is the previous app in the Rack stack. In this case, `app` is `Hello`.

  `call` actually triggers the `call` method on `Hello`, and stores the response into some variables we can play around with. Then, we add a string to the end of the response. Remember, the response content is always an array. This is why we need to call `.first` on our response variable and why, again, we wrap our new `response_body` variable in brackets.

  This will become a little clearer when we see the change we need to make in our `config.ru` file.

6. In `config.ru` add the following two lines at the end:

  ```ruby
  use Randomize
  run Hello.new
  ```

  Looks slightly different than we're used to, no? The `run Hello.new` line looks familiar. This is how we actually run our Rack app. The line above it tells rack that we want to use `Randomize` as a piece of middleware. Now, when requests come in, `Hello` will be initialized, then passed as an argument to `Randomize`'s initialize method.

  Then, the `call` method on `Randomize` is triggered, and the resulting response is sent back to the user.

  Here's the chain of events:

  Request -> app = Hello.new -> randomize = Randomize.new(app) -> randomize.call (which gets the result of app.call) -> Response to User

  It's super confusing, I know. But to see it in action, make sure you are in the `hello-with-middleware` directory and type `rackup` on your command line and then visit [http://localhost:9292](http://localhost:9292) again in your browser. Hit refresh a couple of times. You should see a slightly different response (thanks to our random number generator) each time.

7. If you totally get what's going on, yay! But if you're like me and still a bit confused by the order of things, `cd` into the `middleware-chain` directory and run `rackup` from your command line. Look at the output in your terminal to see the order in which our middleware is initialized. See how its initialized from the bottom up?

  First, `MyApp` (our actual application) is initialized, and then each piece of middleware is initialized in order.

8. Now, visit [http://localhost:9292](http://localhost:9292) in your browser and look at the output in your terminal. You should now see the order in which the middleware was called. First, the top-most piece of middleware is called, which triggers the next piece of middleware, and then finally our app. Looking in your browser, you can see the final, built-up response.
