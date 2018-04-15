require "../src/discordcr-middleware"
require "../src/discordcr-middleware/middleware/prefix"

class CachedEvent
  include Discord::Middleware

  getter! channel : Discord::Channel
  getter guild : Discord::Guild?
  getter member : Discord::GuildMember?
  getter! member_roles : Array(Discord::Role)

  def call(payload : Discord::Message, context : Discord::Context)
    if cache = context[Discord::Client].cache
      message = payload

      @channel = channel = cache.resolve_channel(message.channel_id)
      if id = channel.guild_id
        @guild = guild = cache.resolve_guild(id)
        @member = member = cache.resolve_member(id, message.author.id)

        if guild && member
          @member_roles = guild.roles.select { |r| member.roles.includes? r.id }
        end
      end

      yield
    else
      raise "Must enable the cache on the client to use this middleware!"
    end
  end
end

client = Discord::Client.new("Bot TOKEN")

# Hook up the Cache
cache = Discord::Cache.new(client)
client.cache = cache

client.on_message_create(DiscordMiddleware::Prefix.new("!memberinfo"), CachedEvent.new) do |payload, context|
  distinct = "#{payload.author.username}##{payload.author.discriminator}"
  cached = context[CachedEvent]
  if member = cached.member
    nick = member.nick

    message = <<-DOC
      ```
      User: #{distinct}
      Nickname: #{member.nick.nil? ? "none" : nick}
      Joined #{cached.guild.try &.name}: #{member.joined_at}
      Roles: #{cached.member_roles.map &.name}
      ```
      DOC

    client.create_message(payload.channel_id, message)
  else
    client.create_message(payload.channel_id, "Not in a server..")
  end
end

client.run
