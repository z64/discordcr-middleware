# Middleware that passes if the given message in the context starts with
# a specified string.
# ```
# client.stack(:foo, Prefix.new("!ping")) do |context|
#   channel_id = context.payload.channel_id
#   client.create_message(channel_id, "pong")
# end
# ```
class DiscordMiddleware::Prefix < Discord::Middleware
  def initialize(@prefix : String | Char)
  end

  def call(context : Discord::Context(Discord::Message), done)
    done.call if context.payload.content.starts_with?(@prefix)
  end
end
