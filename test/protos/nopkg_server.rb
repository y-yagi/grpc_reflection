# frozen_string_literal: true

require "test/protos/nopkg_services_pb"

class NoPkgServer < NoPkg::Service
  def ping(ping_req, _unused_call)
    PingReply.new(message: "Pong #{ping_req.name}")
  end
end
