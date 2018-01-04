# Mixin for common helpers to access cached resources
module DiscordMiddleware::CachedRoutes
  private def get_guild(client : Discord::Client, guild_id : UInt64)
    if cache = client.cache
      cache.resolve_guild(guild_id)
    else
      client.get_guild(guild_id)
    end
  end

  private def get_channel(client : Discord::Client, channel_id : UInt64)
    if cache = client.cache
      cache.resolve_channel(channel_id)
    else
      client.get_channel(channel_id)
    end
  end

  private def get_member(client : Discord::Client, guild_id : UInt64,
                         member_id : UInt64)
    if cache = client.cache
      cache.resolve_member(guild_id, member_id)
    else
      client.get_guild_member(guild_id, member_id)
    end
  end
end
