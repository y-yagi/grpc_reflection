# frozen_string_literal: true

require "test_helper"
require_relative "../test/protos/greeter_server"

class TestGrpcReflection < Minitest::Test
  include Minitest::Hooks

  def before_all
    @hostname = "0.0.0.0:50051"
    @server_pid = fork do
      s = GRPC::RpcServer.new
      s.add_http2_port(@hostname, :this_port_is_insecure)
      s.handle(GrpcReflection::Server)
      s.handle(GreeterServer)
      s.run_till_terminated_or_interrupted([1, "int", "SIGTERM"])
    end

    sleep 0.5
  end

  def afer_all
    Process.kill(@server_pid, :TERM)
  end

  def test_list_service
    request = Grpc::Reflection::V1::ServerReflectionRequest.new(list_services: "*")
    stub = Grpc::Reflection::V1::ServerReflection::Stub.new(@hostname, :this_channel_is_insecure)
    response = stub.server_reflection_info([request]).first

    assert_equal 2, response.list_services_response.service.count
    assert_equal ["grpc.reflection.v1.ServerReflection", "helloworld.Greeter"], response.list_services_response.service.map {|s| s.name }.sort
  end
end
