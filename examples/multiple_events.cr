require "../discordcr-middleware"
require "../discordcr-middleware/middleware/prefix"

class TestMiddleware < Discord::Middleware
  def call(context : Discord::Context(Discord::Message), done)
    puts "MESSAGE_CREATE from #{context.payload.author.id}"
    done.call
  end

  def call(context : Discord::Context(Discord::Gateway::PresenceUpdatePayload), done)
    puts "PRESENCE_UPDATE from #{context.payload.user.id}"
    done.call
  end

  def call(context : Discord::Context(Discord::Gateway::GuildMemberUpdatePayload), done)
    puts "MEMBER_UPDATE from #{context.payload.user.id}"
  end
end

client = Discord::Client.new("Bot TOKEN")

client.on_message_create(TestMiddleware.new) do |ctx|
  # Do something
end

client.on_presence_update(TestMiddleware.new) do |ctx|
  # Do something
end

# Pure middleware handler
client.on_guild_member_update(TestMiddleware.new)

# Plain handler, without middleware
client.on_message_create do |payload|
  puts "MESSAGE_CREATE (Regular handler) from #{payload.author.id}"
end

client.run
