require "spec"
require "../src/discordcr-middleware"
require "../src/discordcr-middleware/middleware/*"

Client = Discord::Client.new("Bot TOKEN")
Cache  = Discord::Cache.new(Client)
Client.cache = Cache

def channel
  channel_json = %({"id":"326472371441762304","type":0,"guild_id":"225375815087554563","name":"devs","permission_overwrites":[{"id":"240154291979943939","type":"role","allow":1049600,"deny":0},{"id":"225375815087554563","type":"role","allow":0,"deny":1049600}],"topic":"test","last_message_id":"384577728424181780","nsfw":false})
  Discord::Channel.from_json(channel_json)
end

def message(content = "", author_id = 0)
  message_json = %({"attachments": [], "tts": false, "embeds": [], "timestamp": "2017-11-29T14:41:51.808000+00:00", "mention_everyone": false, "id": "385440229341003776", "pinned": false, "edited_timestamp": null, "author": {"username": "z64", "discriminator": "2639", "id": "#{author_id}", "avatar": "862875f54a2ef6db022512ee0d3b8d20"}, "mention_roles": [], "content": "#{content}", "channel_id": "326472371441762304", "mentions": [], "type": 0})
  Discord::Message.from_json(message_json)
end

# Middleware that tracks if it was called, and how many times
class FlagMiddleware < Discord::Middleware
  getter called = false

  getter counter = 0

  getter message : Discord::Message?

  def call(context, done)
    @called = true
    @counter += 1
    @message = context.message
    done.call
  end
end

# Middleware that will not call the next middleware
class StopMiddleware < Discord::Middleware
  getter called = false

  def call(context, done)
    @called = true
  end
end
