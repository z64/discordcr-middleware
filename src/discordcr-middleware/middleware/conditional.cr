# The Conditional middleware is useful when you want to check one or more
# conditions from the context or elsewhere, but don't want to write
# your own middleware to do it.
class DiscordMiddleware::Conditional
  def initialize(@condition : Proc(Discord::Message, Discord::Context, Bool))
  end

  def call(payload : Discord::Message, context : Discord::Context)
    yield if @condition.call(payload, context)
  end
end
