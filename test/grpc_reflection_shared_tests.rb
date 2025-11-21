# frozen_string_literal: true

module GrpcReflectionSharedTests
  def hostname
    @hostname
  end

  def test_list_service
    request = reflection_module::ServerReflectionRequest.new(list_services: "*")
    stub = reflection_module::ServerReflection::Stub.new(hostname, :this_channel_is_insecure)
    response = stub.server_reflection_info([request]).first

    assert_equal 4, response.list_services_response.service.count
    assert_equal ["grpc.reflection.v1.ServerReflection", "grpc.reflection.v1alpha.ServerReflection", "helloworld.Greeter", "utility.Clock"], response.list_services_response.service.map {|s| s.name }.sort
  end

  def test_file_containing_symbol_by_service_name
    request = reflection_module::ServerReflectionRequest.new(file_containing_symbol: "helloworld.Greeter")
    stub = reflection_module::ServerReflection::Stub.new(hostname, :this_channel_is_insecure)
    response = stub.server_reflection_info([request]).first

    assert response.file_descriptor_response
    parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
    assert_equal "test/protos/helloworld.proto", parsed.name
  end

  def test_file_containing_symbol_that_using_import
    request = reflection_module::ServerReflectionRequest.new(file_containing_symbol: "utility.Clock")
    stub = reflection_module::ServerReflection::Stub.new(hostname, :this_channel_is_insecure)
    response = stub.server_reflection_info([request]).first

    assert response.file_descriptor_response
    parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
    assert_equal "test/protos/utilify.proto", parsed.name
  end

  def test_file_containing_symbol_by_method_name
    request = reflection_module::ServerReflectionRequest.new(file_containing_symbol: "helloworld.Greeter.SayHello")
    stub = reflection_module::ServerReflection::Stub.new(hostname, :this_channel_is_insecure)
    response = stub.server_reflection_info([request]).first

    assert response.file_descriptor_response

    parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
    assert_equal "test/protos/helloworld.proto", parsed.name
  end

  def test_file_by_filename
    request = reflection_module::ServerReflectionRequest.new(file_by_filename: "google/protobuf/timestamp.proto")
    stub = reflection_module::ServerReflection::Stub.new(hostname, :this_channel_is_insecure)
    response = stub.server_reflection_info([request]).first

    assert response.file_descriptor_response

    parsed = Google::Protobuf::FileDescriptorProto.decode(response.file_descriptor_response.file_descriptor_proto.first)
    assert_equal "google/protobuf/timestamp.proto", parsed.name
  end
end
