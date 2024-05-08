# frozen_string_literal: true

require "time"
require "test/protos/utilify_services_pb"

class UtilityServer < Utility::Clock::Service
  def now(_req, _unused_call)
    Utility::ClockReply.new(time: Google::Protobuf::Timestamp.new(seconds: Time.now.to_i))
  end
end
