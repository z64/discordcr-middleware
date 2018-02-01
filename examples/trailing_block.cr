require "../src/discordcr-middleware"

class Prefix < Discord::Middleware
  def initialize(@prefix : String)
  end

  def call(context : Discord::Context(Discord::Message), done)
    done.call if context.payload.content.starts_with?(@prefix)
  end
end

client = Discord::Client.new("Bot TOKEN")

client.on_message_create(Prefix.new("!ping")) do |context|
  channel_id = context.payload.channel_id
  client.create_message(channel_id, "pong")
end

client.run
