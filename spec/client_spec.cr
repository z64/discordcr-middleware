require "./spec_helper"

module Discord
  describe Client do
    context "with multiple event handlers" do
      it "calls stacks and trailing blocks once per event" do
        mw = FlagMiddleware.new
        event = Discord::WebSocket::Packet.new(
          0_i64,
          0_i64,
          IO::Memory.new(message.to_json),
          "MESSAGE_CREATE")

        times_called = 0
        ::Client.on_message_create(mw) { times_called += 1 }
        ::Client.on_message_create(mw) { times_called += 1 }
        ::Client.inject(event)
        sleep 0.1.seconds

        times_called.should eq 2
      end
    end
  end
end
