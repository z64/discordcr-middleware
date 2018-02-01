require "../spec_helper"

describe DiscordMiddleware::Prefix do
  mw = DiscordMiddleware::Prefix.new("!ping")

  context "with a matching string" do
    it "passes" do
      msg = message("!ping")
      context = Discord::Context(Discord::Message).new(Client, msg)

      mw.call(context, ->{ true }).should be_true
    end
  end

  context "with a mismatching string" do
    it "doesn't pass" do
      msg = message("!pong")
      context = Discord::Context(Discord::Message).new(Client, msg)

      mw.call(context, ->{ true }).should be_falsey
    end
  end
end
