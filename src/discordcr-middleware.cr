require "discordcr"
require "./discordcr-middleware/*"

module Discord
  class Client
    macro stack_event(event_name, klass)
      # Creates a `Client#on_{{event_name}}` handler with a middleware chain and
      # trailing block. Handles a `{{klass}}` payload.
      def on_{{event_name}}(*middleware, &block : {{klass}}, Context ->)
        stack = Stack.new(*middleware)
        on_{{event_name}} do |payload|
          context = Discord::Context.new(self)
          stack.run(payload, context, 0, &block)
        end
      end

      # Creates a `Client#on_{{event_name}}` handler with a middleware chain.
      # Handles a `{{klass}}` payload.
      def on_{{event_name}}(*middleware)
        stack = Stack.new(*middleware)
        on_{{event_name}} do |payload|
          context = Discord::Context.new(self)
          stack.run(payload, context)
        end
      end
    end

    stack_event dispatch, {String, IO::Memory}

    stack_event ready, Gateway::ReadyPayload

    stack_event resumed, Gateway::ResumedPayload

    stack_event channel_create, Channel

    stack_event channel_update, Channel

    stack_event channel_delete, Channel

    stack_event guild_create, Gateway::GuildCreatePayload

    stack_event guild_update, Guild

    stack_event guild_delete, Gateway::GuildDeletePayload

    stack_event guild_ban_add, Gateway::GuildBanPayload

    stack_event guild_ban_remove, Gateway::GuildBanPayload

    stack_event guild_emoji_update, Gateway::GuildEmojiUpdatePayload

    stack_event guild_integrations_update, Gateway::GuildIntegrationsUpdatePayload

    stack_event guild_member_add, Gateway::GuildMemberAddPayload

    stack_event guild_member_update, Gateway::GuildMemberUpdatePayload

    stack_event guild_member_remove, Gateway::GuildMemberRemovePayload

    stack_event guild_members_chunk, Gateway::GuildMembersChunkPayload

    stack_event guild_role_create, Gateway::GuildRolePayload

    stack_event guild_role_update, Gateway::GuildRolePayload

    stack_event guild_role_delete, Gateway::GuildRoleDeletePayload

    stack_event message_create, Message

    stack_event message_reaction_add, Gateway::MessageReactionPayload

    stack_event message_reaction_remove, Gateway::MessageReactionPayload

    stack_event message_reaction_remove_all, Gateway::MessageReactionRemoveAllPayload

    stack_event message_update, Gateway::MessageUpdatePayload

    stack_event message_delete, Gateway::MessageDeletePayload

    stack_event message_delete_bulk, Gateway::MessageDeleteBulkPayload

    stack_event presence_update, Gateway::PresenceUpdatePayload

    stack_event typing_start, Gateway::TypingStartPayload

    stack_event user_update, User

    stack_event voice_state_update, VoiceState

    stack_event voice_server_update, Gateway::VoiceServerUpdatePayload
  end
end
