# This middleware provides a method of executing some block after a given
# amount of time from receiving an event.
# ```crystal
# delayed = DiscordMiddleware::Time.new(5.seconds) do |context|
#   channel_id = context.message.channel_id
#   context.client.create_message(channel_id, "I'm back!")
# end
#
# client.stack(:foo, delayed) do |context|
#   channel_id = context.message.channel_id
#   context.client.create_message(channel_id, "Going away for 5 seconds..")
# end
# ```
class DiscordMiddleware::Time < Discord::Middleware
  def initialize(@delay : ::Time::Span, &block : Discord::Context ->)
    @block = block
  end

  def call(context, done)
    spawn do
      sleep @delay
      @block.call(context)
    end

    done.call
  end
end
