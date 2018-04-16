# This middleware provides a method of executing some block after a given
# amount of time from receiving an event.
# ```crystal
# delayed = DiscordMiddleware::Time.new(5.seconds) do |context|
#   channel_id = context.payload.channel_id
#   context.client.create_message(channel_id, "I'm back!")
# end
#
# client.on_message_create(delayed) do |context|
#   channel_id = context.payload.channel_id
#   context.client.create_message(channel_id, "Going away for 5 seconds..")
# end
# ```
class DiscordMiddleware::Time
  def initialize(@delay : ::Time::Span, &block : Discord::Message, Discord::Context ->)
    @block = block
  end

  def call(payload : Discord::Message, context : Discord::Context)
    spawn do
      sleep @delay
      @block.call(payload, context)
    end

    yield
  end
end
