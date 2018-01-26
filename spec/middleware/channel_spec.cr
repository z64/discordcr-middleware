require "../spec_helper"

describe DiscordMiddleware::Channel do
  ch = channel

  describe "#initialize" do
    it "accepts several channel properties to match against" do
      DiscordMiddleware::Channel.new(
        id: 326472371441762304_u64,
        name: "devs",
        topic: "test",
        nsfw: true,
        guild_id: 225375815087554563_u64
      )
    end
  end

  # TODO: No idea how to spec this properly at the moment.
  describe "#channel" do
    context "with a cached client" do
      pending "pulls from the cache" do
      end
    end

    context "without a cached client" do
      pending "makes an http request" do
      end
    end
  end

  describe "#call" do
    # Put our stub channel in the cache so we don't make
    # an HTTP req..
    Cache.cache(channel)

    context "with a matching channel" do
      it "calls the next middleware" do
        mw = DiscordMiddleware::Channel.new(name: "devs")
        context = Discord::Context.new(Client, message)

        mw.call(context, ->{ true }).should be_true
      end
    end

    context "with a channel that doesn't match" do
      it "doesn't call the next middleware" do
        mw = DiscordMiddleware::Channel.new(name: "memes")
        context = Discord::Context.new(Client, message)

        mw.call(context, ->{ true }).should be_falsey
      end
    end
  end
end
