require "./spec_helper"

describe Discord::Client do
  describe "#stacks" do
    it "holds a collection of Stacks" do
      client.stacks.should be_a Hash(Symbol, Discord::Stack)
    end
  end

  describe "#stack" do
    context "with ID and middlewares" do
      it "stores a new stack" do
        c = client
        c.stack(:foo, FlagMiddleware.new)
        c.stacks[:foo].should be_a Discord::Stack
      end
    end

    context "with only ID" do
      it "returns the stack with that ID" do
        c = client
        stack = c.stack(:foo, FlagMiddleware.new)
        c.stack(:foo).should eq stack
      end
    end
  end

  describe "#run_stack" do
    it "passes a message through each stack" do
      middlewares = {FlagMiddleware.new, FlagMiddleware.new}
      c = client
      c.stack(:foo, *middlewares)
      c.stack(:bar, *middlewares)

      m = message
      c.run_stack(m)

      middlewares.each do |mw|
        mw.message.should eq m
        mw.counter.should eq 2
      end
    end
  end
end
