# Matches the channel the message event was raised from based on
# several different attributes. If the client has a cache enabled,
# it will be used to resolve the channel the message came from.
class DiscordMiddleware::Channel < Discord::Middleware
  include AttributeMiddleware

  def initialize(@id : UInt64? = nil, @name : String? = nil,
                 @topic : String? = nil, @nsfw : Bool? = nil,
                 @is_private : Bool? = nil, @guild_id : UInt64? = nil,
                 @type : UInt8? = nil)
  end

  # The channel from the message event
  private def channel(context)
    channel_id = context.message.channel_id

    if cache = context.client.cache
      cache.resolve_channel(channel_id)
    else
      context.client.get_channel(channel_id)
    end
  end

  def call(context, done)
    ch = channel(context)

    check_attributes(ch)

    done.call
  end
end
