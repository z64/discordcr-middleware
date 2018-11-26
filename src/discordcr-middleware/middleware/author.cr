require "./attribute"

# Matches the author the message event was raised with based
# on several different attributes.
class DiscordMiddleware::Author
  include AttributeMiddleware

  def initialize(@id : UInt64? = nil, @username : String? = nil,
                 @discriminator : String? = nil, @bot : Bool? = nil)
  end

  def call(payload : Discord::Message, context : Discord::Context)
    author = payload.author
    check_attributes(author)
    yield
  end
end
