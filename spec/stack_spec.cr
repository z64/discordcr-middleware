require "./spec_helper"

describe Discord::Stack do
  describe "#initialize" do
    it "stores a tuple of middleware as an array" do
      stack = Discord::Stack.new(Client, FlagMiddleware.new)
      stack.@middlewares.should be_a Array(Discord::Middleware)
    end
  end

  describe "#run" do
    it "calls each middleware" do
      middlewares = {FlagMiddleware.new, FlagMiddleware.new, FlagMiddleware.new}
      stack = Discord::Stack.new(Client, *middlewares)
      stack.run(message)

      middlewares.each do |mw|
        mw.called.should be_true
      end
    end

    context "with a middleware that doesn't send done.call" do
      it "doesn't continue" do
        middlewares = {FlagMiddleware.new, StopMiddleware.new, FlagMiddleware.new}
        stack = Discord::Stack.new(Client, *middlewares)
        stack.run(message)

        (middlewares[0].called && middlewares[1].called).should be_true
        middlewares[2].called.should be_false
      end
    end
  end
end
