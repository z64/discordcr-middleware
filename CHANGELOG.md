# Changelog

## v0.4.0

This release accomplishes a small redesign of `Stack` and `Context`  that makes the library simpler and more powerful for end users.

- `Discord::Middleware` has been removed
- `Discord.add_ctx_property` / `Discord.add_ctx_property!` has been removed
- Middleware can now be *any* class that implements `def call(payload, context, &block)`
- The middleware chain is advanced by `yield`-ing to the block passed to `call`
- `Context` is reimplemented as a table of references
- The client the middleware was registered on can be accessed as `context[Discord::Client]`
- Each middleware in a chain is made available on `context`, i.e. `context[MyMiddleware]`

Big thanks to @RX14 for the recommendations and code examples that were the foundation of these changes.

See the updated `README.md` and documentation for more details.

## v0.3.1

Fixes a bug where stacks were registered across event handlers incorrectly, causing events to be distributed wrongly

## v0.3.0

This is a large update that adds support for plugin chains on every kind of event handler.
See `README.md` for more details on this.

### Breaking changes:

- `Client#stack(id, *middleware)` etc. has been removed. Replace with `Client#on_message_create(*middlewares)`
- `Context#message` is now `Context#payload`, as it is now a generic type for any kind of payload.

**NOTE:** In your middleware, you may have to restrict `context` in `def call(context, done)` as `context : Discord::Context(Discord::Message)`

### General changes

- You can now use middleware chains on any discord event. YAY!
- Likewise, a single middleware class can be used for multiple event handlers. Simply define `def call` with `context` restricted for each kind of payload you want to handle.
- `Context` now contains some basic, common use-case properties for storing string, integers, and a hash. See its documentation for specifics.

## v0.2.1

Bugfix release

## v0.2.0

Adds collection of stock middleware for common use cases

## v0.1.0

Initial release
