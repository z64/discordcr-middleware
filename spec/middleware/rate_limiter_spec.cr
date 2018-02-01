require "../spec_helper"

describe DiscordMiddleware::RateLimiter do
  limiter = RateLimiter(UInt64).new
  limiter.bucket(:foo, 1_u32, 1.seconds)

  describe "#call" do
    context "when not rate limited" do
      it "calls the next middleware" do
        mw = DiscordMiddleware::RateLimiter.new(
          limiter,
          :foo
        )
        ctx = Discord::Context(Discord::Message).new(Client, message)

        mw.call(ctx, ->{ true }).should be_true
      end
    end

    context "when rate limited" do
      it "doesn't call the next middleware" do
        mw = DiscordMiddleware::RateLimiter.new(
          limiter,
          :foo
        )
        ctx = Discord::Context(Discord::Message).new(Client, message)

        mw.call(ctx, ->{ true })
        mw.call(ctx, ->{ true }).should be_falsey
      end

      context "with a new key" do
        it "calls the next middleware" do
          mw = DiscordMiddleware::RateLimiter.new(
            limiter,
            :foo
          )

          msg_a = message(author_id: 0)
          ctx_a = Discord::Context(Discord::Message).new(Client, msg_a)

          msg_b = message(author_id: 1)
          ctx_b = Discord::Context(Discord::Message).new(Client, msg_b)

          mw.call(ctx_a, ->{ true })
          mw.call(ctx_a, ->{ true }).should be_falsey
          mw.call(ctx_b, ->{ true }).should be_true
        end
      end
    end
  end
end
