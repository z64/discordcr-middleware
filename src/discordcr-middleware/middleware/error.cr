# This middleware immediately calls the next middleware in the chain, and if
# any subsequent middleware raises an exception, it will be caught by this
# middleware allowing the user to trigger additional handling. Such as,
# for example, responding to the user with an error message or doing
# extra logging at the time of exception.
#
# It can be initialized with a string that will be used as a canned response.
# The text "%exception%" will be replaced with the exception's message if
# provided. Alternatively, it can be initialized with a block for any other
# custom behavior.
class DiscordMiddleware::Error
  def initialize(message : String)
    @message = message
    @block = nil
  end

  def initialize(&block : Discord::Message, Discord::Context ->)
    @message = nil
    @block = block
  end

  def call(payload : Discord::Message, context : Discord::Context)
    yield
  rescue ex
    if message = @message
      channel_id = payload.channel_id
      message = message.gsub("%exception%", ex.message)
      context[Discord::Client].create_message(channel_id, message)
    end

    @block.try &.call(payload, context)

    raise ex
  end
end
