# discordcr-middleware

An extension of [discordcr's](https://github.com/meew0/discordcr) `Client` that adds middleware functionality, similar to that of webserver libraries.
The goal is provide a very customizable way to conditionally execute event handlers, and make great reuse of code and state between events.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  discordcr-middleware:
    github: z64/discordcr-middleware
```

## Usage

Require the extension:
```crystal
require "discordcr-middleware"

```

### Creating Middleware

Custom middleware inherits from `Discord::Middleware` and implements `def call(context, done)`.
```crystal
class MyMiddleware < Discord::Middleware
  def call(context : Discord::Context(Discord::Message), done)
    # Do things with `context` here..
    # ..
    # Now call the next middleware in the chain:
    done.call
  end
end
```
`context` is an instance of `Discord::Context(P)`, which contains a reference to your `Client` and tthe payload of type `P`, which in this case is the invoking `Message`.

A custom middleware can be used for multiple kinds of events by adding multiple methods that restrict `context` to the specific payload type.

```crystal
class MyMiddleware < Discord::Middleware
  def call(context : Discord::Context(Discord::Message), done)
    # Handle Discord::Message payloads
    done.call
  end

  def call(context : Discord::Context(Discord::Gateway::PresenceUpdatePayload), done)
    # Handle Discord::Gateway::PresenceUpdatePayload payloads
    done.call
  end
end
```

`done` represents the next middleware in the chain, which is grabbed and subsequently called lazily. **If you do not send `done.call`,** the rest of the middleware chain won't be executed. Use this to leverage flow control across the middleware chain.

Currently, if you try to use a middleware on an event handler where the middleware does *not* have a matching `#call` method restricted appropriately, it will throw a runtime error.

```cr
# OK
client.on_message_create(MyMiddleware.new)

# OK
client.on_presence_update(MyMiddleware.new)

# Runtime error! :(
client.on_guild_member_update(MyMiddleware.new)
```

You can also extend `Context` class and add more custom properties to be set and shared between middleware, just like you would a class with `property` and `property!`:

```crystal
# Add `Context#db_user`, with type `Database::UserModel?`
Discord.add_ctx_property(db_user, Database::UserModel)

# Add `Context#db_user`, with type `Database::UserModel`
# This performs a `not_nil!` assertion whenever you try to call it to guarantee the type to the compiler.
# You are responsible for ensuring it will never be `nil`.
Discord.add_ctx_property!(db_user, Database::UserModel)
```

And use it in some middleware:
```crystal
Discord.add_ctx_property!(db_user, Database::UserModel)

class UserQuery < Discord::Middleware
  def call(context : Discord::Context(Discord::Message), done)
    author_id = context.message.author.id
    user = Database::UserModel.find(discord_id: author_id)
    context.db_user = user

    # Only call the next middleware if the user was in our DB,
    # otherwise send an error message
    if user
      done.call
    else
      channel_id = context.message.channel_id
      context.client.create_message(channel_id, "User not found")
    end
  end
end
```

`Middleware#initialize` is not defined, so you can define this to accept any arguments to customize the behavior of your middleware per-handler.
```crystal
class Prefix < Discord::Middleware
  def initialize(@prefix : String)
  end

  def call(context : Discord::Context(Discord::Message), done)
    # Only call the next middleware if the prefix matches:
    done.call if context.message.content.starts_with?(@prefix)
  end
end

client.on_message_create(Prefix.new("!")) do |context|
  # Message started with "!"
end

client.on_message_create(Prefix.new("?")) do |context|
  # Message started with "?"
end
```

### Usage with Client

Middleware can be applied to any event handler in a few styles.

With a block:
```crystal
client.on_messgae_create(Prefix.new("!dbinfo"), UserQuery.new) do |context|
  # Access our custom context property that our middleware set:
  results = context.query_results

  channel_id = context.message.channel_id

  # Send back some info about our database row..
  client.create_message(channel_id, results.to_s)
end
```

As a pure middleware chain without a block:
```crystal
client.on_message_create(MiddlewareA.new, MiddlewareB.new)
```

When the associated event is dispatched, it will be passed through each of your middleware sequentially, with the same `context` instance. If you supply a block, you can access that `context` instance that passed through your middleware, and the invoking payload is available as `context.payload`.

Note, that if you do not pass *any* middleware, it is the same as the base event handler method. It will be passed the raw payload (*not* wrapped in a `Context`):

```cr
client.on_message_create(MyMiddleware.new) do |context|
  context #=> Context(Discord::Message)
  context.payload #=> Discord::Message
end

client.on_message_create do |payload|
  payload #=> Discord::Message
end
```

### [Additional Examples](https://github.com/z64/discordcr-middleware/tree/master/examples)

## Stock Middleware

A collection of basic, common use-case middleware are provided in [`discordcr-middleware/middleware`](src/discordcr-middleware/middleware).

Require them explicitly to make use of them:

```crystal
require "discordcr-middleware/middleware/prefix"

DiscordMiddleware::Prefix.new("!help")
```

## Contributors

- [z64](https://github.com/z64)  - creator, maintainer

*Inspired by the [raze](https://razecr.com/) web framework and its [middleware system](https://razecr.com/docs/middlewares).*
