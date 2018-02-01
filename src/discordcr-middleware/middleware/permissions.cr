# This middleware evaluates the permissions of the calling message author.
#
# If the message is from a guild, the guilds roles and the current channels
# permissions will be taken into account according to the members roles.
# Otherwise, `DM_PERMISSIONS` will be considered.
#
# If the client has a cache enabled, it will be used to fetch the guild
# and channel.
#
# ```
# # Require that a user has permission to kick members to trigger this
# # handler
# perms = Discord::Permissions::KickMembers
#
# client.stack(:kick, PREFIX, DiscordMiddleware::Permissions.new(perms)) do |ctx|
#   # Kick 'em
# end
# ```
class DiscordMiddleware::Permissions < Discord::Middleware
  include DiscordMiddleware::CachedRoutes

  # The permissions a user has in a direct message
  DM_PERMISSIONS = Discord::Permissions.flags(
    ManageChannels,
    AddReactions,
    ReadMessages,
    SendMessages,
    SendTTSMessages,
    EmbedLinks,
    AttachFiles,
    ReadMessageHistory,
    MentionEveryone,
    UseExternalEmojis,
    Connect,
    Speak,
    UseVAD
  )

  def initialize(@permissions : Discord::Permissions)
  end

  # Returns the member's base permissions on the guild
  # :nodoc:
  def base_permissions_for(member, in guild)
    return Discord::Permissions::All if guild.owner_id == member.user.id

    perms = Discord::Permissions::None

    guild.roles.each do |role|
      if member.roles.includes?(role.id) || role.id == guild.id
        perms |= role.permissions
      end
    end

    return Discord::Permissions::All if perms.administrator?

    perms
  end

  # Returns the applicable overwrite permissions
  # :nodoc:
  def overwrites_for(member, in channel, with base_permissions)
    return Discord::Permissions::All if base_permissions.administrator?

    if overwrites = channel.permission_overwrites
      # @everyone overwrite
      overwrites.find { |o| o.id == channel.guild_id && o.type == "role" }.try do |o|
        base_permissions &= ~o.deny
        base_permissions |= o.allow
      end

      # Role overwrites
      allow = Discord::Permissions::None
      deny = Discord::Permissions::None
      overwrites.each do |o|
        if member.roles.includes?(o.id) && o.type == "role"
          allow |= o.allow
          deny |= o.deny
        end
      end

      base_permissions &= ~deny
      base_permissions |= allow

      # User overwrite
      overwrites.find { |o| o.id == member.user.id && o.type == "user" }.try do |o|
        base_permissions &= ~o.deny
        base_permissions |= o.allow
      end
    end

    base_permissions
  end

  def call(context : Discord::Context(Discord::Message), done)
    channel = get_channel(context.client, context.payload.channel_id)
    user_id = context.payload.author.id

    if guild_id = channel.guild_id
      guild = get_guild(context.client, guild_id)

      # Pass if the user is the owner of the guild
      return done.call if guild.owner_id == user_id

      member = get_member(context.client, guild_id, user_id)
      permissions = base_permissions_for(member, in: guild)

      # Pass if user has an administrator role
      return done.call if permissions.administrator?

      # Evaluate channel overwrites
      overwrites = overwrites_for(member, in: channel, with: permissions)

      done.call if (@permissions & overwrites) == @permissions
    else
      done.call if (@permissions & DM_PERMISSIONS) == @permissions
    end
  end
end
