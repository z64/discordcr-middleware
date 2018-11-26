require "../src/discordcr-middleware"
require "../src/discordcr-middleware/middleware/cached_event"
require "../src/discordcr-middleware/middleware/prefix"

client = Discord::Client.new("Bot TOKEN")

# Hook up the Cache
cache = Discord::Cache.new(client)
client.cache = cache

client.on_message_create(DiscordMiddleware::Prefix.new("!memberinfo"), DiscordMiddleware::CachedEvent.new) do |payload, context|
  cached = context[DiscordMiddleware::CachedEvent::Result]
  distinct = "#{payload.author.username}##{payload.author.discriminator}"
  if member = cached.member
    nick = member.nick

    message = <<-DOC
      ```
      User: #{distinct}
      Nickname: #{member.nick.nil? ? "none" : nick}
      Joined #{cached.guild.not_nil!.name}: #{member.joined_at}
      Roles: #{cached.member_roles.not_nil!.map &.name}
      ```
      DOC

    client.create_message(payload.channel_id, message)
  else
    client.create_message(payload.channel_id, "Not in a server..")
  end
end

client.run
