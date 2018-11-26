require "../spec_helper"
require "../../src/discordcr-middleware/middleware/author"

describe DiscordMiddleware::Author do
  describe "#initialize" do
    it "accepts several author properties to match against" do
      DiscordMiddleware::Author.new(
        id: 120571255635181568_u64,
        username: "z64",
        discriminator: "2639"
      )
    end
  end

  describe "#call" do
    context "with a matching author" do
      it "calls the next middleware" do
        mw = DiscordMiddleware::Author.new(id: 0, username: "z64")
        context = Discord::Context.new

        mw.call(message, context) { true }.should be_true
      end
    end

    context "with a author that doesn't match" do
      it "doesn't call the next middleware" do
        mw = DiscordMiddleware::Author.new(username: "y32")
        context = Discord::Context.new

        mw.call(message, context) { true }.should be_falsey
      end
    end
  end
end
