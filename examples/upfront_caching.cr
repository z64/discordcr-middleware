require "../src/discordcr-middleware"

Discord.add_ctx_property! channel, Discord::Channel
Discord.add_ctx_property guild, Discord::Guild?
Discord.add_ctx_property member, Discord::GuildMember?
Discord.add_ctx_property! member_roles, Array(Discord::Role)

class CachedEvent < Discord::Middleware
  def call(context, done)
    if cache = context.client.cache
      message = context.message

      channel = context.channel = cache.resolve_channel(message.channel_id)
      if id = channel.guild_id
        guild = context.guild = cache.resolve_guild(id)
        member = context.member = cache.resolve_member(id, message.author.id)

        if guild && member
          context.member_roles = guild.roles.select { |r| member.roles.includes? r.id }
        end
      end

      done.call
    else
      raise "Must enable the cache on the client to use this middleware!"
    end
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

# Hook up the Cache
cache = Discord::Cache.new(client)
client.cache = cache

client.stack(:member, Prefix.new("!memberinfo"), CachedEvent.new) do |context|
  distinct = "#{context.message.author.username}##{context.message.author.discriminator}"
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
