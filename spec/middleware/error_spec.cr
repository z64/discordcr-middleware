require "../spec_helper"
require "../../src/discordcr-middleware/middleware/error"

describe DiscordMiddleware::Error do
  describe "#initialize" do
    it "accepts a string" do
      DiscordMiddleware::Error.new("foo")
    end

    it "accepts a block" do
      DiscordMiddleware::Error.new { |ctx| nil }
    end
  end

  describe "#call" do
    it "calls the next middleware" do
      mw = DiscordMiddleware::Error.new("foo")
      context = Discord::Context.new(Client)
      mw.call(message, context) { true }.should be_true
    end

    context "when the next middleware raises" do
      it "forwards the exception" do
        mw = DiscordMiddleware::Error.new { }
        context = Discord::Context.new(Client)
        msg = message

        expect_raises(Exception) do
          mw.call(msg, context) { raise "exception" }
        end
      end

      context "when given a block" do
        it "calls it" do
          called = false
          mw = DiscordMiddleware::Error.new { called = true }
          context = Discord::Context.new(Client)

          begin
            mw.call(message, context) { raise "exception" }
          rescue
          end

          called.should be_true
        end
      end

      context "within a stack" do
        it "rescues from the entire chain" do
          called = false
          mw = DiscordMiddleware::Error.new { called = true }
          stack = Discord::Stack.new(mw)
          context = Discord::Context.new(Client)

          begin
            stack.run(message, context) { raise "exception" }
          rescue
          end

          called.should be_true
        end
      end
    end

    context "when the next middleware doesn't raise" do
      context "when given a block" do
        it "doesn't call it" do
          called = false
          mw = DiscordMiddleware::Error.new { called = true }
          context = Discord::Context.new(Client)

          begin
            mw.call(message, context) { true }
          rescue
          end

          called.should be_falsey
        end
      end
    end
  end
end
