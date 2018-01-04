require "./cached_routes"

# Add properties onto our context storage
Discord.add_ctx_property! channel, Discord::Channel
Discord.add_ctx_property guild, Discord::Guild?
Discord.add_ctx_property member, Discord::GuildMember?
Discord.add_ctx_property! member_roles, Array(Discord::Role)

module DiscordMiddleware
  # When a message is passed through this middleware, it caches several
  # common properties one might make for typical commands:
  # - The channel the message was from
  # - The guild the message was from
  # - The member the message was from
  # - The member's roles
  # ```
  # client.stack(:member, DiscordMiddleware::Prefix.new("!info"), DiscordMiddleware::CachedEvent.new) do |ctx|
  #   ctx.channel      # => Channel
  #   ctx.guild        # => Guild?
  #   ctx.member       # => Member?
  #   ctx.member_roles # => Array(Role)
  # end
  # ```
  # If the cache is enabled on the client (recommended) it will be used.
  class CachedEvent < Discord::Middleware
    include DiscordMiddleware::CachedRoutes

    def call(ctx, done)
      ctx.channel = channel = get_channel(ctx.client, ctx.message.channel_id)

      if guild_id = channel.guild_id
        ctx.guild = guild = get_guild(ctx.client, guild_id)
        ctx.member = member = get_member(ctx.client, guild_id, ctx.message.author.id)
        ctx.member_roles = guild.roles.select { |r| member.roles.includes?(r.id) }
      end

      done.call
    end
  end
end
