require "./spec_helper"

class TestMiddleware < Discord::Middleware
  property called = false

  def call(context : Discord::Context(Int32), done)
    @called = true
    done.call
  end

  def call(context : Discord::Context(String), done)
    @called = true
    done.call
  end
end

describe Discord::Stack do
  describe "#initialize" do
    it "stores a tuple of middleware as an array" do
      stack = Discord::Stack.new(FlagMiddleware.new)
      stack.@middlewares.should be_a Array(Discord::Middleware)
    end
  end

  describe "#run" do
    it "calls each middleware" do
      middlewares = {TestMiddleware.new, TestMiddleware.new}
      stack = Discord::Stack.new(*middlewares)
      stack.run(Discord::Context(Int32).new(Client, 1))

      middlewares.each do |mw|
        mw.called.should be_true
      end
    end

    it "runs middleware handles multiple kinds of events" do
      middleware = TestMiddleware.new
      stack = Discord::Stack.new(middleware)

      int_context = Discord::Context(Int32).new(Client, 1)
      str_context = Discord::Context(String).new(Client, "foo")

      stack.run(int_context)
      middleware.called.should be_true
      middleware.called = false

      stack.run(str_context)
      middleware.called.should be_true
    end

    it "raises for unsupported event types" do
      middleware = TestMiddleware.new
      stack = Discord::Stack.new(middleware)
      context = Discord::Context(Symbol).new(Client, :unsupported)

      expect_raises(Exception, "TestMiddleware does not support Discord::Context(Symbol)!") do
        stack.run(context)
      end
    end

    context "with a middleware that doesn't send done.call" do
      it "doesn't continue" do
        middlewares = {FlagMiddleware.new, StopMiddleware.new, FlagMiddleware.new}
        stack = Discord::Stack.new(*middlewares)
        context = Discord::Context(Discord::Message).new(Client, message)

        stack.run(context)
        (middlewares[0].called && middlewares[1].called).should be_true
        middlewares[2].called.should be_false
      end
    end

    it "accepts a block" do
      stack = Discord::Stack.new(TestMiddleware.new, TestMiddleware.new)
      context = Discord::Context(Int32).new(Client, 1)

      ran = false
      stack.run(context) do |ctx|
        ran = true
      end

      ran.should be_true
    end
  end
end
