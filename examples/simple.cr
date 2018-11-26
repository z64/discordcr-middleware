require "../src/discordcr-middleware"

# A basic middleware to cache the Channel and Guild from the invoking
# message. The attached client can be accessed by `context.client`.
class Cached
  class Result
    getter channel : Discord::Channel
    getter guild : Discord::Guild?

    def initialize(@channel : Discord::Channel, @guild : Discord::Guild? = nil)
    end
  end

  def call(payload : Discord::Message, context : Discord::Context)
    client = context[Discord::Client]
    channel = client.get_channel(payload.channel_id)

    if id = channel.guild_id
      guild = client.get_guild(id)
      context.put(Result.new(channel, guild))
    else
      context.put(Result.new(channel))
    end

    yield
  end
end

# A basic, customizable prefix check
class Prefix
  def initialize(@prefix : String)
  end

  def call(payload : Discord::Message, context : Discord::Context)
    yield if payload.content.starts_with?(@prefix)
  end
end

# Responds to the channel with some basic information
class Test
  def call(payload : Discord::Message, context : Discord::Context, &block)
    info = <<-DOC
    Channel: #{context[Cached::Result].channel.name}
    Guild: #{context[Cached::Result].guild.try &.name}
    DOC

    context[Discord::Client].create_message(payload.channel_id, info)
  end
end

client = Discord::Client.new("Bot TOKEN")

# The middlewares are run in order, and the next one will only be executed
# if that middleware runs `done.call`.
#
# The `Prefix` middleware does `done.call` conditionally, so if the prefix
# condition isn't met, the next middleware in the stack won't run.
#
# Since `Middleware` does not define `#initialize`, it is used here to set the prefix
# it will check for. This also means `Prefix` can be reused on any `stack`.
client.on_message_create(Prefix.new("!test"), Cached.new, Test.new)

client.run
