require "./spec_helper"

describe Discord::Stack do
  describe "#initialize" do
    it "stores a tuple of middleware as an array" do
      client = Discord::Client.new("")
      stack = Discord::Stack.new(client, FlagMiddleware.new)
      stack.@middlewares.should be_a Array(Discord::Middleware)
    end
  end

  describe "#run" do
    it "calls each middleware" do
      client = Discord::Client.new("")
      middlewares = {FlagMiddleware.new, FlagMiddleware.new, FlagMiddleware.new}
      stack = Discord::Stack.new(client, *middlewares)
      stack.run(message)

      middlewares.each do |mw|
        mw.called.should be_true
      end
    end
  end
end
