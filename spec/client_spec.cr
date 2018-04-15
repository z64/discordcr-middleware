require "./spec_helper"

module Discord
  describe Client do
    message_json = %({"attachments": [], "tts": false, "embeds": [], "timestamp": "2017-11-29T14:41:51.808000+00:00", "mention_everyone": false, "id": "385440229341003776", "pinned": false, "edited_timestamp": null, "author": {"username": "z64", "discriminator": "2639", "id": "123", "avatar": "862875f54a2ef6db022512ee0d3b8d20"}, "mention_roles": [], "content": "foo", "channel_id": "326472371441762304", "mentions": [], "type": 0})

    context "with multiple event handlers" do
      it "calls stacks and trailing blocks once per event" do
        mw = FlagMiddleware.new
        event = Discord::WebSocket::Packet.new(
          0_i64,
          0_i64,
          IO::Memory.new(message_json),
          "MESSAGE_CREATE")

        times_called = 0
        ::Client.on_message_create(mw) { times_called += 1 }
        ::Client.on_message_create(mw) { times_called += 1 }
        ::Client.inject(event)
        sleep 0.1.seconds

        times_called.should eq 2
      end
    end

    it "makes each middleware available on context" do
      mw = FlagMiddleware.new
      event = Discord::WebSocket::Packet.new(
        0_i64,
        0_i64,
        IO::Memory.new(message_json),
        "MESSAGE_CREATE")

      channel = ::Channel(Nil).new
      ::Client.on_message_create(mw) do |payload, context|
        context[FlagMiddleware].should eq mw
        channel.send(nil)
      end
      ::Client.inject(event)
      channel.receive
    end
  end
end
