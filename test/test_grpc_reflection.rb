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

    sleep 0.5
  end

  def after_all
    Process.kill(:TERM, @server_pid)
    Process.wait(@server_pid)
  end

  def test_list_service
    request = Grpc::Reflection::V1::ServerReflectionRequest.new(list_services: "*")
    stub = Grpc::Reflection::V1::ServerReflection::Stub.new(@hostname, :this_channel_is_insecure)
    response = stub.server_reflection_info([request]).first

    assert_equal 4, response.list_services_response.service.count
    assert_equal ["grpc.reflection.v1.ServerReflection", "grpc.reflection.v1alpha.ServerReflection", "helloworld.Greeter", "utility.Clock"], response.list_services_response.service.map {|s| s.name }.sort
  end

  def test_file_containing_symbol_by_service_name
    request = Grpc::Reflection::V1::ServerReflectionRequest.new(file_containing_symbol: "helloworld.Greeter")
    stub = Grpc::Reflection::V1::ServerReflection::Stub.new(@hostname, :this_channel_is_insecure)
    response = stub.server_reflection_info([request]).first

    assert response.file_descriptor_response
    parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
    assert_equal "test/protos/helloworld.proto", parsed.name
  end

  def test_file_containing_symbol_that_using_import
    request = Grpc::Reflection::V1::ServerReflectionRequest.new(file_containing_symbol: "utility.Clock")
    stub = Grpc::Reflection::V1::ServerReflection::Stub.new(@hostname, :this_channel_is_insecure)
    response = stub.server_reflection_info([request]).first

    assert response.file_descriptor_response
    parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
    assert_equal "test/protos/utilify.proto", parsed.name
  end

  def test_file_containing_symbol_by_method_name
    request = Grpc::Reflection::V1::ServerReflectionRequest.new(file_containing_symbol: "helloworld.Greeter.SayHello")
    stub = Grpc::Reflection::V1::ServerReflection::Stub.new(@hostname, :this_channel_is_insecure)
    response = stub.server_reflection_info([request]).first

    assert response.file_descriptor_response
    parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
    assert_equal "test/protos/helloworld.proto", parsed.name
  end

  # v1 Alpha

  def test_list_service_alpha
    request = Grpc::Reflection::V1alpha::ServerReflectionRequest.new(list_services: "*")
    stub = Grpc::Reflection::V1alpha::ServerReflection::Stub.new(@hostname, :this_channel_is_insecure)
    response = stub.server_reflection_info([request]).first

    assert_equal 4, response.list_services_response.service.count
    assert_equal ["grpc.reflection.v1.ServerReflection", "grpc.reflection.v1alpha.ServerReflection", "helloworld.Greeter", "utility.Clock"], response.list_services_response.service.map {|s| s.name }.sort
  end

  def test_file_containing_symbol_by_service_name_alpha
    request = Grpc::Reflection::V1alpha::ServerReflectionRequest.new(file_containing_symbol: "helloworld.Greeter")
    stub = Grpc::Reflection::V1alpha::ServerReflection::Stub.new(@hostname, :this_channel_is_insecure)
    response = stub.server_reflection_info([request]).first

    assert response.file_descriptor_response
    parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
    assert_equal "test/protos/helloworld.proto", parsed.name
  end

  def test_file_containing_symbol_that_using_import_alpha
    request = Grpc::Reflection::V1alpha::ServerReflectionRequest.new(file_containing_symbol: "utility.Clock")
    stub = Grpc::Reflection::V1alpha::ServerReflection::Stub.new(@hostname, :this_channel_is_insecure)
    response = stub.server_reflection_info([request]).first

    assert response.file_descriptor_response
    parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
    assert_equal "test/protos/utilify.proto", parsed.name
  end

  def test_file_containing_symbol_by_method_name_alpha
    request = Grpc::Reflection::V1alpha::ServerReflectionRequest.new(file_containing_symbol: "helloworld.Greeter.SayHello")
    stub = Grpc::Reflection::V1alpha::ServerReflection::Stub.new(@hostname, :this_channel_is_insecure)
    response = stub.server_reflection_info([request]).first

    assert response.file_descriptor_response

    parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
    assert_equal "test/protos/helloworld.proto", parsed.name
  end

end
