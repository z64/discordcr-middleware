# Changelog

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
