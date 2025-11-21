# frozen_string_literal: true

require_relative "test_helper"
require_relative "../test/protos/greeter_server"
require_relative "../test/protos/utility_server"

# load the client service into memory - we should not be adding this to our output
require_relative '../test/protos/client_services_pb'

class TestGrpcReflection < Minitest::Test
  include Minitest::Hooks

  def before_all
    @hostname = "0.0.0.0:50051"
    @server_pid = fork do
      s = GRPC::RpcServer.new
      s.add_http2_port(@hostname, :this_port_is_insecure)
      s.handle(GrpcReflection::Server)
      s.handle(GrpcReflection::ServerAlpha)
      s.handle(GreeterServer)
      s.handle(UtilityServer)
      s.run_till_terminated_or_interrupted([1, "int", "SIGTERM"])
    end

    @versions = %i[v1 v1alpha]
    @requests = {v1: Grpc::Reflection::V1::ServerReflectionRequest, v1alpha: Grpc::Reflection::V1alpha::ServerReflectionRequest}
    @stubs = {v1: Grpc::Reflection::V1::ServerReflection::Stub, v1alpha: Grpc::Reflection::V1alpha::ServerReflection::Stub}
    sleep 0.5
  end

  def after_all
    Process.kill(:TERM, @server_pid)
    Process.wait(@server_pid)
  end

  def test_list_service
    @versions.each do |version|
      request = @requests[version].new(list_services: "*")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first

      assert_equal 4, response.list_services_response.service.count
      assert_equal ["grpc.reflection.v1.ServerReflection", "grpc.reflection.v1alpha.ServerReflection", "helloworld.Greeter", "utility.Clock"], response.list_services_response.service.map {|s| s.name }.sort
    end
  end

  def test_file_containing_symbol_by_service_name
    @versions.each do |version|
      request = @requests[version].new(file_containing_symbol: "helloworld.Greeter")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first

      assert response.file_descriptor_response
      parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
      assert_equal "test/protos/helloworld.proto", parsed.name
    end
  end

  def test_file_containing_symbol_that_using_import
    @versions.each do |version|
      request = @requests[version].new(file_containing_symbol: "utility.Clock")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first

      assert response.file_descriptor_response
      parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
      assert_equal "test/protos/utilify.proto", parsed.name
    end
  end

  def test_file_containing_symbol_by_method_name
    @versions.each do |version|
      request = @requests[version].new(file_containing_symbol: "helloworld.Greeter.SayHello")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first

      assert response.file_descriptor_response

      parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
      assert_equal "test/protos/helloworld.proto", parsed.name
    end
  end

  def test_file_by_filename
    @versions.each do |version|
      request = @requests[version].new(file_by_filename: "google/protobuf/timestamp.proto")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first

      assert response.file_descriptor_response

      parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
      assert_equal "google/protobuf/timestamp.proto", parsed.name
    end
  end

  def test_file_containing_symbol_by_message_name
    @versions.each do |version|
      request = @requests[version].new(file_containing_symbol: "helloworld.HelloRequest")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first

      assert response.file_descriptor_response
      parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
      assert_equal "test/protos/helloworld.proto", parsed.name
    end
  end
end
