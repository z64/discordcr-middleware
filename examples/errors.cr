require "../src/discordcr-middleware"

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

class Prefix < Discord::Middleware
  def initialize(@prefix : String)
  end

  def call(context, done)
    done.call if context.message.content.starts_with?(@prefix)
  end
end

client = Discord::Client.new("Bot TOKEN")

client.stack(:error, Prefix.new("!test"), ErrorCatcher.new) do |context|
  raise "Woops!"
end

client.run

