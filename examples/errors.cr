require "../src/discordcr-middleware"
require "../src/discordcr-middleware/middleware/prefix"

# Because `done.call` nests for each middleware in the chain, you can rescue
# from any exception that happens later in the stack and handle it. Here we
# raise an Exception in the trailing block, it is caught by ErrorCatcher
# middleware, which responds with a heartfelt apology and passes the error up.

class ErrorCatcher < Discord::Middleware
  def call(context, done)
    done.call
  rescue ex
    channel_id = context.message.channel_id
    context.client.create_message(channel_id, "Sorry, an error occurred: #{ex}")
    raise ex
  end
end

client = Discord::Client.new("Bot TOKEN")

client.stack(:error, DiscordMiddleware::Prefix.new("!test"), ErrorCatcher.new) do |context|
  raise "Woops!"
end

client.run
