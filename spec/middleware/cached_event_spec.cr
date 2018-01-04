require "../spec_helper"

describe DiscordMiddleware::CachedEvent do
  Cache.cache(guild)
  Cache.cache(channel)
  Cache.cache(member, guild.id)

  it "always calls the next middleware" do
    mw = DiscordMiddleware::CachedEvent.new
    context = Discord::Context.new(Client, message(author_id: 120571255635181568))
    mw.call(context, ->{ true }).should be_true
  end

  it "caches each property" do
    mw = DiscordMiddleware::CachedEvent.new
    context = Discord::Context.new(Client, message(author_id: 120571255635181568))

    test = ->do
      context.channel.should eq channel
      context.guild.should eq guild
      context.member.should eq member
      context.member_roles.map(&.id).should eq member.roles
    end

    mw.call(context, test)
  end
end
