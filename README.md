# discordcr-middleware

An extension of [discordcr's](https://github.com/meew0/discordcr) `Client` that
adds middleware functionality, similar to that of webserver libraries. The goal
is to provide a very customizable way to conditionally execute event handlers,
and make great reuse of code and state between events.

- [Documentation](https://z64.github.io/discordcr-middleware)

## Deprecation notice

The functionality provided by this shard is now built into discordcr. It
**should not** be used, as it would duplicate a bunch of code.

Eventually this repo will be reorganized to host *only* the stock middleware.
If you still want to use them, you can just specifically require them instead
of requiring the entire extension.

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

Any class that implements `def call(payload, context, &block)` can be used as
middleware:

```crystal
class Middleware
  def call(payload, context)
    # Do things with payload and context..
    yield
  end
end
```

`payload` is the `Discord` event payload that triggered the event handler. A
middleware can be designed to handle multiple kinds of payloads by overloading
`call` and restricting `payload` to different types:

```crystal
class Middleware
  def call(payload : Discord::Message, context)
    # Do things with a message..
    yield
  end

  def call(payload : Discord::Gateway::PresenceUpdatePayload, context)
    # Do things with a presence update..
    yield
  end
end
```

If you try to use a middleware class with an event that it doesn't support,
this will result in a compile-time error.

`context` is an instance of `Context`. This is a special class that allows
you to store arbitrary `class` objects to be referenced later in the middleware
chain. How the library handles `context` and how it should be used will be
outlined in the next section, but in brief:

```crystal
class Foo
end

foo = Foo.new
context.put(foo)
context[Foo] == foo # => true
```

The `&block` passed to `call` is a block to be yielded to that
determines whether or not middleware that follow should be executed.

You can define an `#initialize` for your middleware that will let you configure
how you want your middleware to behave for different event handlers, as opposed
to creating another middleware class with extremely similar behavior.

### Usage with Client

Any event handler can have a middleware chain applied to it.

The event handling process goes like this:

1. The message event is received by the client
2. An "empty" `Context` is initialized, and the receiving `Client` is added
to it
3. Each middleware in the chain is added to `Context`. This allows you to
access the middleware that have run previously in the chain, either
from inside one of the middleware or in the event handler itself.
4. The event is passed through each middleware, providing that each one
successfully `yield`s. If any middleware does not `yield`, execution
of the rest of the chain will stop.

```crystal
client.on_message_create(MiddlewareA.new, MiddlewareB.new) do |payload, context|
  payload # => Discord::Message
  context # => Discord::Context
  context[Discord::Client] == client # => true
  context[MiddlewareA]               # => MiddlewareA
  context[MiddlewareB]               # => MiddlewareB
end
```

It's also worth noting you can share the same instance of a middleware between
multiple event handlers:

```crystal
middleware = Middleware.new

client.on_message_create(middleware) do |payload|
  # ...
end

client.on_message_update(middleware) do |payload|
  # ...
end
```

This is useful, for example, for a middleware that has some kind of state that
affects multiple handlers. You could have a single `Prefix` middleware instance
that stores the client's prefix in memory, so that when you update the prefix,
the runtime behavior on all of your handlers updates at once.

The event handler block is also optional, making it possible to have
pure-middleware chains:

```crystal
client.on_message_create(MiddlewareA.new, MiddlewareB.new)
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
