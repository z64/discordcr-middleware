# Matches the channel the message event was raised from based on
# several different attributes. If the client has a cache enabled,
# it will be used to resolve the channel the message came from.
class DiscordMiddleware::Channel < Discord::Middleware
  include AttributeMiddleware
  include CachedRoutes

  def initialize(@id : UInt64? = nil, @name : String? = nil,
                 @topic : String? = nil, @nsfw : Bool? = nil,
                 @guild_id : UInt64? = nil, @type : UInt8? = nil)
  end

  def call(context : Discord::Context(Discord::Message), done)
    ch = get_channel(context.client, context.payload.channel_id)

    check_attributes(ch)

    done.call
  end
end
