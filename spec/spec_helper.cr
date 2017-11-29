require "spec"
require "../src/discordcr-middleware"

def client
  Discord::Client.new("Bot TOKEN")
end

def message
  message_json = %({"attachments": [], "tts": false, "embeds": [], "timestamp": "2017-11-29T14:41:51.808000+00:00", "mention_everyone": false, "id": "385440229341003776", "pinned": false, "edited_timestamp": null, "author": {"username": "z64", "discriminator": "2639", "id": "120571255635181568", "avatar": "862875f54a2ef6db022512ee0d3b8d20"}, "mention_roles": [], "content": "test", "channel_id": "246283902652645376", "mentions": [], "type": 0})
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
