require "./spec_helper"

class TestMiddleware
  include Discord::Middleware
  property called = false

  def call(payload : Int32, context)
    @called = true
    yield
  end

  def call(payload : String, context)
    @called = true
    yield
  end
end

describe Discord::Stack do
  describe "#initialize" do
    it "stores a tuple of middleware as an array" do
      stack = Discord::Stack.new(FlagMiddleware.new)
      stack.@middlewares.should be_a Tuple(FlagMiddleware)
    end
  end

  describe "#run" do
    it "calls each middleware" do
      middlewares = {TestMiddleware.new, TestMiddleware.new}
      stack = Discord::Stack.new(*middlewares)
      stack.run(1, Discord::Context.new(Client))

      middlewares.each do |mw|
        mw.called.should be_true
      end
    end

    it "runs middleware handles multiple kinds of events" do
      middleware = TestMiddleware.new
      stack = Discord::Stack.new(middleware)
      context = Discord::Context.new(Client)

      stack.run(1, context)
      middleware.called.should be_true
      middleware.called = false

      stack.run("foo", context)
      middleware.called.should be_true
    end

    context "with a middleware that doesn't send done.call" do
      it "doesn't continue" do
        middlewares = {FlagMiddleware.new, StopMiddleware.new, FlagMiddleware.new}
        stack = Discord::Stack.new(*middlewares)
        context = Discord::Context.new(Client)

        stack.run(message, context)
        (middlewares[0].called && middlewares[1].called).should be_true
        middlewares[2].called.should be_false
      end
    end

    it "accepts a block" do
      stack = Discord::Stack.new(TestMiddleware.new, TestMiddleware.new)
      context = Discord::Context.new(Client)

      ran = false
      stack.run(1, context) do |ctx|
        ran = true
      end

      ran.should be_true
    end
  end
end
