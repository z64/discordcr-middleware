require "../spec_helper"
require "../../src/discordcr-middleware/middleware/cached_routes"
require "../../src/discordcr-middleware/middleware/cached_event"

describe DiscordMiddleware::CachedEvent do
  Cache.cache(guild)
  Cache.cache(channel)
  Cache.cache(member, guild.id)

  it "always calls the next middleware" do
    mw = DiscordMiddleware::CachedEvent.new
    context = Discord::Context.new
    context.put(Client)
    mw.call(message(author_id: 120571255635181568), context) { true }.should be_true
  end

  it "caches each property" do
    mw = DiscordMiddleware::CachedEvent.new
    context = Discord::Context.new
    context.put(Client)

    mw.call(message(author_id: 120571255635181568), context) { true }
    result = context[DiscordMiddleware::CachedEvent::Result]
    result.channel.should eq channel
    result.guild.should eq guild
    result.member.should eq member
    result.member_roles.try(&.map(&.id)).should eq member.roles
  end
end
