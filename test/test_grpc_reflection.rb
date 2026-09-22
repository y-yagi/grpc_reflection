# frozen_string_literal: true

require_relative "test_helper"
require_relative "../test/protos/greeter_server"
require_relative "../test/protos/utility_server"
require_relative "../test/protos/nopkg_server"

# load the client service into memory - we should not be adding this to our output
require_relative '../test/protos/client_services_pb'

class TestGrpcReflection < Minitest::Test
  include Minitest::Hooks

  def before_all
    reader, writer = IO.pipe
    @server_pid = fork do
      reader.close
      s = GRPC::RpcServer.new
      port = s.add_http2_port("127.0.0.1:0", :this_port_is_insecure)
      s.handle(GrpcReflection::Server)
      s.handle(GrpcReflection::ServerAlpha)
      s.handle(GreeterServer)
      s.handle(UtilityServer)
      s.handle(NoPkgServer)

      decoy = GRPC::RpcServer.new
      decoy.add_http2_port("127.0.0.1:0", :this_port_is_insecure)
      decoy.handle(GreeterServer)

      Thread.new do
        s.wait_till_running
        writer.puts(port)
        writer.close
      end
      s.run_till_terminated_or_interrupted([1, "int", "SIGTERM"])
    end
    writer.close
    @hostname = "127.0.0.1:#{reader.gets.to_i}"
    reader.close

    @versions = %i[v1 v1alpha]
    @requests = {v1: Grpc::Reflection::V1::ServerReflectionRequest, v1alpha: Grpc::Reflection::V1alpha::ServerReflectionRequest}
    @stubs = {v1: Grpc::Reflection::V1::ServerReflection::Stub, v1alpha: Grpc::Reflection::V1alpha::ServerReflection::Stub}
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

      assert_equal 5, response.list_services_response.service.count
      assert_equal ["NoPkg", "grpc.reflection.v1.ServerReflection", "grpc.reflection.v1alpha.ServerReflection", "helloworld.Greeter", "utility.Clock"], response.list_services_response.service.map {|s| s.name }.sort
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

  def test_file_containing_symbol_by_service_name_without_package
    @versions.each do |version|
      request = @requests[version].new(file_containing_symbol: "NoPkg")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first

      assert response.file_descriptor_response
      parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
      assert_equal "test/protos/nopkg.proto", parsed.name
    end
  end

  def test_file_containing_symbol_by_method_name_without_package
    @versions.each do |version|
      request = @requests[version].new(file_containing_symbol: "NoPkg.Ping")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first

      assert response.file_descriptor_response
      parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
      assert_equal "test/protos/nopkg.proto", parsed.name
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

  def test_file_containing_symbol_by_nested_enum_name
    @versions.each do |version|
      request = @requests[version].new(file_containing_symbol: "utility.ClockReply.Zone")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first

      assert response.file_descriptor_response
      parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
      assert_equal "test/protos/utilify.proto", parsed.name
    end
  end

  def test_file_containing_symbol_by_field_name
    @versions.each do |version|
      request = @requests[version].new(file_containing_symbol: "utility.ClockReply.time")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first

      assert response.file_descriptor_response
      parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
      assert_equal "test/protos/utilify.proto", parsed.name
    end
  end

  def test_file_containing_symbol_for_well_known_type
    @versions.each do |version|
      request = @requests[version].new(file_containing_symbol: "google.protobuf.Timestamp")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first

      assert response.file_descriptor_response
      parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
      assert_equal "google/protobuf/timestamp.proto", parsed.name
    end
  end

  def test_file_containing_extension
    extension_requests = { v1: Grpc::Reflection::V1::ExtensionRequest, v1alpha: Grpc::Reflection::V1alpha::ExtensionRequest }

    @versions.each do |version|
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)

      extension_request = extension_requests[version].new(containing_type: "google.protobuf.EnumValueOptions", extension_number: 50002)
      request = @requests[version].new(file_containing_extension: extension_request)
      response = stub.server_reflection_info([request]).first
      assert response.file_descriptor_response
      parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
      assert_equal "test/protos/enum_description_option.proto", parsed.name

      extension_request = extension_requests[version].new(containing_type: "google.protobuf.MethodOptions", extension_number: 50001)
      request = @requests[version].new(file_containing_extension: extension_request)
      response = stub.server_reflection_info([request]).first
      assert response.file_descriptor_response
      parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
      assert_equal "test/protos/utilify.proto", parsed.name

      extension_request = extension_requests[version].new(containing_type: "google.protobuf.EnumValueOptions", extension_number: 50001)
      request = @requests[version].new(file_containing_extension: extension_request)
      response = stub.server_reflection_info([request]).first
      refute response.file_descriptor_response
      assert response.error_response
      assert_equal GRPC::Core::StatusCodes::NOT_FOUND, response.error_response.error_code

      extension_request = extension_requests[version].new(containing_type: "unknown.Type", extension_number: 50002)
      request = @requests[version].new(file_containing_extension: extension_request)
      response = stub.server_reflection_info([request]).first
      refute response.file_descriptor_response
      assert response.error_response
      assert_equal GRPC::Core::StatusCodes::NOT_FOUND, response.error_response.error_code
    end
  end

  def test_file_containing_symbol_not_found
    @versions.each do |version|
      request = @requests[version].new(file_containing_symbol: "helloworld.NoSuchSymbol")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first

      refute response.file_descriptor_response
      assert response.error_response
      assert_equal GRPC::Core::StatusCodes::NOT_FOUND, response.error_response.error_code
      assert_equal request, response.original_request
    end
  end

  def test_file_by_filename_not_found
    @versions.each do |version|
      request = @requests[version].new(file_by_filename: "no/such/file.proto")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first

      refute response.file_descriptor_response
      assert response.error_response
      assert_equal GRPC::Core::StatusCodes::NOT_FOUND, response.error_response.error_code
    end
  end

  def test_file_by_filename_with_non_file_symbol
    @versions.each do |version|
      request = @requests[version].new(file_by_filename: "helloworld.HelloRequest")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first

      refute response.file_descriptor_response
      assert response.error_response
      assert_equal GRPC::Core::StatusCodes::NOT_FOUND, response.error_response.error_code
    end
  end

  def test_empty_request
    @versions.each do |version|
      request = @requests[version].new(host: "localhost")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first

      refute response.file_descriptor_response
      assert response.error_response
      assert_equal GRPC::Core::StatusCodes::INVALID_ARGUMENT, response.error_response.error_code
    end
  end

  def test_all_extension_numbers_of_type
    @versions.each do |version|
      request = @requests[version].new(all_extension_numbers_of_type: ".")
      stub = @stubs[version].new(@hostname, :this_channel_is_insecure)
      response = stub.server_reflection_info([request]).first
      refute response.file_descriptor_response
      assert response.error_response
      assert_equal GRPC::Core::StatusCodes::UNIMPLEMENTED, response.error_response.error_code
    end
  end
end
