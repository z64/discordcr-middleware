# Matches the channel the message event was raised from based on
# several different attributes. If the client has a cache enabled,
# it will be used to resolve the channel the message came from.
class DiscordMiddleware::Channel
  include Discord::Middleware
  include AttributeMiddleware
  include CachedRoutes

  def initialize(@id : UInt64? = nil, @name : String? = nil,
                 @topic : String? = nil, @nsfw : Bool? = nil,
                 @guild_id : UInt64? = nil, @type : UInt8? = nil)
  end

  def call(payload : Discord::Message, context : Discord::Context)
    client = context[Discord::Client]
    ch = get_channel(client, payload.channel_id)
    check_attributes(ch)
    yield
  end
end
