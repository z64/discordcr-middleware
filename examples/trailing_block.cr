require "../src/discordcr-middleware"

class Prefix
  include Discord::Middleware

  def initialize(@prefix : String)
  end

  def call(payload : Discord::Message, context : Discord::Context)
    yield if payload.content.starts_with?(@prefix)
  end
end

client = Discord::Client.new("Bot TOKEN")

client.on_message_create(Prefix.new("!ping")) do |payload|
  channel_id = payload.channel_id
  client.create_message(channel_id, "pong")
end

client.run
