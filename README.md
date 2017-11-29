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
  def call(context, done)
    # Do things with `context` here..
    # ..
    # Now call the next middleware in the chain:
    done.call
  end
end
```
`context` is an instance of `Discord::Context`, which contains a reference to your `Client` and the invoking `Message`.

`done` represents the next middleware in the chain, which is grabbed and subsequently called lazily. **If you do not send `done.call`,** the rest of the middleware chain won't be executed. Use this to leverage flow control across the middleware stack.

You can also extend `Context` and add more custom properties to be set and shared between middleware, just like you would a class with `property` and `property!`:

```crystal
# Add `Context#db_user`, with type `Database::UserModel?`
Discord.add_ctx_property(db_user, Database::UserModel)

# Add `Context#db_user`, with type `Database::UserModel`
# This performs a `not_nil!` assertion whenever you try to call it to guarentee the type to the compliler.
# You are responsible for ensuring it will never be `nil`.
Discord.add_ctx_property!(db_user, Database::UserModel)
```

And use it in some middleware:
```crystal
Discord.add_ctx_property!(db_user, Database::UserModel)

class UserQuery < Discord::Middleware
  def call(context, done)
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

`Middleware#initialize` is not defined, so you can define this to accept any arguments to customize the behavior of your middleware per-stack.
```crystal
class Prefix < Discord::Middleware
  def initialize(@prefix : String)
  end

  def call(context, done)
    # Only call the next middleware if the prefix matches:
    done.call if context.message.content.starts_with?(@prefix)
  end
end
```

### Creating Stacks

Stacks represent a chain of middleware that are executed in succession.

Stacks can be registered on the `Client` with `Client#stack` and are uniquely identified with a symbol.

```crystal
client.stack(:db_info, Prefix.new('!dbinfo'), UserQuery.new) do |context|
  user = context.db_user
  channel_id = context.message.channel_id

  # Send back some info about our database row..
  client.create_message(channel_id, user.to_s)
end
```

Stacks can be made with a "trailing block" like above, or consist purely of middleware.
```crystal
client.stack(:foo, MiddlewareA.new, MiddlewareB.new)
```

### [Additional Examples](https://github.com/z64/discordcr-middleware/tree/master/examples)

## Contributors

- [z64](https://github.com/z64)  - creator, maintainer
