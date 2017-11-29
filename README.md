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

```crystal
require "discordcr-middleware"
```

See the `examples` folder.

## Contributors

- [z64](https://github.com/z64)  - creator, maintainer
