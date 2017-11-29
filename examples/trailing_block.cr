require "../src/discordcr-middleware"

class Prefix < Discord::Middleware
  def initialize(@prefix : String)
  end

  def call(context, done)
    done.call if context.message.content.starts_with?(@prefix)
  end
end

client = Discord::Client.new("Bot TOKEN")

client.stack :ping, Prefix.new("!ping") do |context|
  channel_id = context.message.channel_id
  client.create_message(channel_id, "pong")
end

client.run
