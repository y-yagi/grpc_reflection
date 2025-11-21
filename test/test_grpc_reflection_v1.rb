# frozen_string_literal: true

require_relative "test_helper"
require_relative "grpc_reflection_shared_tests"
require_relative "../test/protos/greeter_server"
require_relative "../test/protos/utility_server"

# load the client service into memory - we should not be adding this to our output
require_relative '../test/protos/client_services_pb'

class TestGrpcReflectionV1 < Minitest::Test
  include Minitest::Hooks
  include GrpcReflectionSharedTests

  def before_all
    @hostname = "0.0.0.0:50051"
    @server_pid = fork do
      s = GRPC::RpcServer.new
      s.add_http2_port(@hostname, :this_port_is_insecure)
      s.handle(GrpcReflection::Server)
      s.handle(GreeterServer)
      s.handle(UtilityServer)
      s.run_till_terminated_or_interrupted([1, "int", "SIGTERM"])
    end

    sleep 1
  end

  def after_all
    Process.kill(:TERM, @server_pid)
    Process.wait(@server_pid)
  end

  private

  def reflection_module
    Grpc::Reflection::V1
  end
end
