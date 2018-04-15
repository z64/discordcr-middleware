require "../spec_helper"
require "../../src/discordcr-middleware/middleware/cached_routes"
require "../../src/discordcr-middleware/middleware/permissions"

describe DiscordMiddleware::Permissions do
  describe "#base_permissions_for" do
    it "returns the members permissions" do
      perms = Discord::Permissions.flags(SendMessages, ReadMessages)
      mw = DiscordMiddleware::Permissions.new(perms)
      stub_member = member(1)

      mw.base_permissions_for(stub_member, in: guild).should eq perms
    end

    context "when member is the guild owner" do
      it "returns all permissions" do
        perms = Discord::Permissions.flags(SendMessages, ReadMessages)
        mw = DiscordMiddleware::Permissions.new(perms)

        mw.base_permissions_for(member, in: guild).should eq Discord::Permissions::All
      end
    end

    context "when member has administrator" do
      pending "returns all permissions" do
      end
    end
  end

  describe "#overwrites_for" do
    # TODO: Everyone overwrite
    # TODO: User overwrite
    it "returns the members permissions" do
      perms = Discord::Permissions.flags(SendMessages, ReadMessages)
      mw = DiscordMiddleware::Permissions.new(perms)
      stub_member = member(1)

      mw.overwrites_for(stub_member, in: channel, with: perms).should eq Discord::Permissions.flags(ReadMessages, CreateInstantInvite)
    end

    context "when member has administrator" do
      pending "returns all permissions" do
      end
    end
  end

  describe "#call" do
    Cache.cache(guild)
    Cache.cache(channel)
    Cache.cache(member(1), guild.id)

    context "with sufficient permissions" do
      it "calls the next middleware" do
        perms = Discord::Permissions.flags(ReadMessages, CreateInstantInvite)
        mw = DiscordMiddleware::Permissions.new(perms)

        context = Discord::Context.new
        context.put(Client)
        mw.call(message(author_id: 1), context) { true }.should be_true
      end
    end

    context "with insufficient permissions" do
      it "doesn't call the next middleware" do
        perms = Discord::Permissions.flags(SendMessages, ReadMessages, CreateInstantInvite)
        mw = DiscordMiddleware::Permissions.new(perms)

        context = Discord::Context.new
        context.put(Client)
        mw.call(message(author_id: 1), context) { true }.should be_falsey
      end
    end
  end
end
