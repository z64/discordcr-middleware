require "./cached_routes"

module DiscordMiddleware
  # When a message is passed through this middleware, it caches several
  # common properties one might make for typical commands:
  # - The channel the message was from
  # - The guild the message was from
  # - The member the message was from
  # - The member's roles
  # ```
  # client.on_message_create(DiscordMiddleware::Prefix.new("!info"), DiscordMiddleware::CachedEvent.new) do |ctx|
  #   ctx.channel      # => Channel
  #   ctx.guild        # => Guild?
  #   ctx.member       # => Member?
  #   ctx.member_roles # => Array(Role)
  # end
  # ```
  # If the cache is enabled on the client (recommended) it will be used.
  class CachedEvent
    include Discord::Middleware
    include DiscordMiddleware::CachedRoutes

    getter! channel : Discord::Channel
    getter guild : Discord::Guild?
    getter member : Discord::GuildMember?
    getter! member_roles : Array(Discord::Role)

    def call(payload : Discord::Message, context : Discord::Context)
      client = context[Discord::Client]
      @channel = channel = get_channel(client, payload.channel_id)

      if guild_id = channel.guild_id
        @guild = guild = get_guild(client, guild_id)
        @member = member = get_member(client, guild_id, payload.author.id)
        @member_roles = guild.roles.select { |r| member.roles.includes?(r.id) }
      end

      yield
    end
  end
end
