require "../src/discordcr-middleware"
require "../src/discordcr-middleware/middleware/prefix"

Discord.add_ctx_property! channel, Discord::Channel
Discord.add_ctx_property guild, Discord::Guild?
Discord.add_ctx_property member, Discord::GuildMember?
Discord.add_ctx_property! member_roles, Array(Discord::Role)

class CachedEvent
  include Discord::Middleware

  def call(payload : Discord::Message, context : Discord::Context)
    if cache = context.client.cache
      message = payload

      channel = context.channel = cache.resolve_channel(message.channel_id)
      if id = channel.guild_id
        guild = context.guild = cache.resolve_guild(id)
        member = context.member = cache.resolve_member(id, message.author.id)

        if guild && member
          context.member_roles = guild.roles.select { |r| member.roles.includes? r.id }
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
  if member = context.member
    nick = member.nick

    message = <<-DOC
      ```
      User: #{distinct}
      Nickname: #{member.nick.nil? ? "none" : nick}
      Joined #{context.guild.try &.name}: #{member.joined_at}
      Roles: #{context.member_roles.map &.name}
      ```
      DOC

    client.create_message(context.channel.id, message)
  else
    client.create_message(context.channel.id, "Not in a server..")
  end
end

client.run
