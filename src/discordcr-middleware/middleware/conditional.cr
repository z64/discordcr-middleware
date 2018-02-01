# The Conditional middleware is useful when you want to check one or more
# conditions from the context or elsewhere, but don't want to write
# your own middleware to do it.
class DiscordMiddleware::Conditional
  def initialize(@condition : Proc(Discord::Context(Discord::Message), Bool))
  end

  def call(context : Discord::Context(Discord::Message), done)
    done.call if @condition.call(context)
  end
end
