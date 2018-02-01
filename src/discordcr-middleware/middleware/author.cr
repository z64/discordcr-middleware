# Matches the author the message event was raised with based
# on several different attributes.
class DiscordMiddleware::Author < Discord::Middleware
  include AttributeMiddleware

  def initialize(@id : UInt64? = nil, @username : String? = nil,
                 @discriminator : String? = nil, @bot : Bool? = nil)
  end

  def call(context : Discord::Context(Discord::Message), done)
    author = context.payload.author

    check_attributes(author)

    done.call
  end
end
