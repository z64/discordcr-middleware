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
class DiscordMiddleware::Time < Discord::Middleware
  def initialize(@delay : ::Time::Span, &block : Discord::Context(Discord::Message) ->)
    @block = block
  end

  def call(context : Discord::Context(Discord::Message), done)
    spawn do
      sleep @delay
      @block.call(context)
    end

    done.call
  end
end
