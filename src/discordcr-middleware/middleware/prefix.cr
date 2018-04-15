# Middleware that passes if the given message in the context starts with
# a specified string.
# ```
# client.on_message_create(Prefix.new("!ping")) do |context|
#   channel_id = context.payload.channel_id
#   client.create_message(channel_id, "pong")
# end
# ```
class DiscordMiddleware::Prefix
  include Discord::Middleware

  def initialize(@prefix : String | Char)
  end

  def call(payload : Discord::Message, context : Discord::Context)
    yield if payload.content.starts_with?(@prefix)
  end
end
