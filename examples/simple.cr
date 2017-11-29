require "../src/discordcr-middleware"

# Extend the `Context` class with some custom properties to share
# state between middlewares
Discord.add_ctx_property!(channel, Discord::Channel)
Discord.add_ctx_property(guild, Discord::Guild?)

# A basic middleware to cache the Channel and Guild from the invoking
# message. The attached client can be accessed by `context.client`.
class Common < Discord::Middleware
  def call(context, done)
    channel = context.channel = context.client.get_channel(context.message.channel_id)
    if id = channel.guild_id
      context.guild = context.client.get_guild(id)
    end
    done.call
  end
end

# A basic, customizable prefix check
class Prefix < Discord::Middleware
  def initialize(@prefix : String)
  end

  def call(context, done)
    done.call if context.message.content.starts_with?(@prefix)
  end
end

# Responds to the channel with some basic information
class Test < Discord::Middleware
  def call(context, done)
    info = <<-DOC
    Channel: #{context.channel.name}
    Guild: #{context.guild.try &.name}
    DOC

    context.client.create_message(context.channel.id, info)
  end
end

client = Discord::Client.new("Bot TOKEN")

# Creates a new stack uniquely named :test.
#
# The middlewares are run in order, and the next one will only be executed
# if that middleware runs `done.call`.
#
# The `Prefix` middleware does `done.call` conditionally, so if the prefix
# condition isn't met, the next middleware in the stack won't run.
#
# Since `Middleware` does not define `#initialize`, it is used here to set the prefix
# it will check for. This also means `Prefix` can be reused on any `stack`.
client.stack(:test, Common.new, Prefix.new("!test"), Test.new)

client.run
