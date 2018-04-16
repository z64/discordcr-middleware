require "spec"
require "../src/discordcr-middleware"

Client = Discord::Client.new("Bot TOKEN")
Cache  = Discord::Cache.new(Client)
Client.cache = Cache

# TODO: Refactor to load JSON from files for stubs
# Channel stub
def channel
  channel_json = %({"id":"326472371441762304","type":0,"guild_id":"225375815087554563","name":"devs","permission_overwrites":[{"id": "1", "type": "role", "allow": 1, "deny": 2048}],"topic":"test","last_message_id":"384577728424181780","nsfw":false})
  Discord::Channel.from_json(channel_json)
end

# Member stub
def member(id = "120571255635181568")
  member_json = %({"deaf": false, "joined_at": "2016-09-13T22:03:01.633000+00:00", "user": {"username": "z64", "discriminator": "2639", "id": "#{id}", "avatar": "c6c94c8a225348a4f93a81dd00c96efc"}, "roles": ["1"], "mute": false})
  Discord::GuildMember.from_json(member_json)
end

# Guild stub
def guild
  guild_json = %({"mfa_level": 0, "emojis": [], "application_id": null, "name": "Y32", "roles": [{"hoist": false, "id": "225375815087554563", "name": "everyone", "permissions": 1024, "color": 0, "position": 0, "managed": false, "mentionable": true}, {"id": "1", "name": "snapcase", "permissions": 2048, "color": 0, "hoist": true, "position": 1, "managed": true, "mentionable": true}], "afk_timeout": 300, "system_channel_id": "345687437722386433", "widget_channel_id": null, "region": "us-east", "default_message_notifications": 0, "embed_channel_id": null, "explicit_content_filter": 0, "splash": null, "features": [], "afk_channel_id": null, "widget_enabled": false, "verification_level": 0, "owner_id": "120571255635181568", "embed_enabled": false, "id": "225375815087554563", "icon": "70edbed16d93b9615af82948ded07962"})
  Discord::Guild.from_json(guild_json)
end

# Message stub
def message(content = "", author_id = 0)
  message_json = %({"attachments": [], "tts": false, "embeds": [], "timestamp": "2017-11-29T14:41:51.808000+00:00", "mention_everyone": false, "id": "385440229341003776", "pinned": false, "edited_timestamp": null, "author": {"username": "z64", "discriminator": "2639", "id": "#{author_id}", "avatar": "862875f54a2ef6db022512ee0d3b8d20"}, "mention_roles": [], "content": "#{content}", "channel_id": "326472371441762304", "mentions": [], "type": 0})
  Discord::Message.from_json(message_json)
end

# Middleware that tracks if it was called, and how many times
class FlagMiddleware
  getter called = false

  getter counter = 0

  getter message : Discord::Message?

  def call(payload : Discord::Message, context)
    @called = true
    @counter += 1
    @message = payload
    yield
  end
end

# Middleware that will not call the next middleware
class StopMiddleware
  getter called = false

  def call(payload : Discord::Message, context, &block)
    @called = true
  end
end
