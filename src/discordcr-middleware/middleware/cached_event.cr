require "./cached_routes"

module DiscordMiddleware
  # When a message is passed through this middleware, it caches several
  # common properties one might make for typical commands:
  # - The channel the message was from
  # - The guild the message was from
  # - The member the message was from
  # - The member's roles
  # ```
  # client.on_message_create(
  #   DiscordMiddleware::Prefix.new("!info"),
  #   DiscordMiddleware::CachedEvent.new) do |payload, context|
  #   cached = context[DiscordMiddleware::CachedEvent::Result]
  #   cached.channel      # => Channel
  #   cached.guild        # => Guild?
  #   cached.member       # => Member?
  #   cached.member_roles # => Array(Role)?
  # end
  # ```
  # If the cache is enabled on the client (recommended) it will be used.
  class CachedEvent
    include DiscordMiddleware::CachedRoutes

    class Result
      getter channel : Discord::Channel
      getter guild : Discord::Guild?
      getter member : Discord::GuildMember?
      getter member_roles : Array(Discord::Role)?

      def initialize(@channel : Discord::Channel, @guild : Discord::Guild? = nil,
                     @member : Discord::GuildMember? = nil,
                     @member_roles : Array(Discord::Role)? = nil)
      end
    end

    def call(payload : Discord::Message, context : Discord::Context)
      client = context[Discord::Client]
      channel = get_channel(client, payload.channel_id)

      if guild_id = channel.guild_id
        guild = get_guild(client, guild_id)
        member = get_member(client, guild_id, payload.author.id)
        member_roles = guild.roles.select { |r| member.roles.includes?(r.id) }
        context.put(Result.new(channel, guild, member, member_roles))
      else
        context.put(Result.new(channel))
      end

      yield
    end
  end
end
