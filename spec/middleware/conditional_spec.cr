require "../spec_helper"
require "../../src/discordcr-middleware/middleware/conditional"

describe DiscordMiddleware::Conditional do
  describe "#initialize" do
    it "takes a block that returns a bool" do
      mw = DiscordMiddleware::Conditional.new ->(payload : Discord::Message, ctx : Discord::Context) { true }
      mw.@condition.should be_a Proc(Discord::Message, Discord::Context, Bool)
    end
  end

  describe "#call" do
    mw = DiscordMiddleware::Conditional.new ->(payload : Discord::Message, ctx : Discord::Context) do
      payload.content == "!ping"
    end

    context "when truthy" do
      it "calls the next middleware" do
        msg = message("!ping")
        context = Discord::Context.new(Client)
        mw.call(msg, context) { true }.should be_true
      end
    end

    context "when falsey" do
      it "doesn't call the next middleware" do
        msg = message("!pong")
        context = Discord::Context.new(Client)
        mw.call(msg, context) { true }.should be_falsey
      end
    end
  end
end
