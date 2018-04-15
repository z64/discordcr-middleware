require "../spec_helper"
require "../../src/discordcr-middleware/middleware/cached_routes"
require "../../src/discordcr-middleware/middleware/cached_event"

describe DiscordMiddleware::CachedEvent do
  Cache.cache(guild)
  Cache.cache(channel)
  Cache.cache(member, guild.id)

  it "always calls the next middleware" do
    mw = DiscordMiddleware::CachedEvent.new
    context = Discord::Context.new(Client)
    mw.call(message(author_id: 120571255635181568), context) { true }.should be_true
  end

  it "caches each property" do
    mw = DiscordMiddleware::CachedEvent.new
    context = Discord::Context.new(Client)

    mw.call(message(author_id: 120571255635181568), context) { true }
    context.channel.should eq channel
    context.guild.should eq guild
    context.member.should eq member
    context.member_roles.map(&.id).should eq member.roles
  end
end
