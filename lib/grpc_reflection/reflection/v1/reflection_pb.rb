# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: src/proto/grpc/reflection/v1/reflection.proto

require 'google/protobuf'


descriptor_data = "\n-src/proto/grpc/reflection/v1/reflection.proto\x12\x12grpc.reflection.v1\"\x85\x02\n\x17ServerReflectionRequest\x12\x0c\n\x04host\x18\x01 \x01(\t\x12\x1a\n\x10\x66ile_by_filename\x18\x03 \x01(\tH\x00\x12 \n\x16\x66ile_containing_symbol\x18\x04 \x01(\tH\x00\x12I\n\x19\x66ile_containing_extension\x18\x05 \x01(\x0b\x32$.grpc.reflection.v1.ExtensionRequestH\x00\x12\'\n\x1d\x61ll_extension_numbers_of_type\x18\x06 \x01(\tH\x00\x12\x17\n\rlist_services\x18\x07 \x01(\tH\x00\x42\x11\n\x0fmessage_request\"E\n\x10\x45xtensionRequest\x12\x17\n\x0f\x63ontaining_type\x18\x01 \x01(\t\x12\x18\n\x10\x65xtension_number\x18\x02 \x01(\x05\"\xb8\x03\n\x18ServerReflectionResponse\x12\x12\n\nvalid_host\x18\x01 \x01(\t\x12\x45\n\x10original_request\x18\x02 \x01(\x0b\x32+.grpc.reflection.v1.ServerReflectionRequest\x12N\n\x18\x66ile_descriptor_response\x18\x04 \x01(\x0b\x32*.grpc.reflection.v1.FileDescriptorResponseH\x00\x12U\n\x1e\x61ll_extension_numbers_response\x18\x05 \x01(\x0b\x32+.grpc.reflection.v1.ExtensionNumberResponseH\x00\x12I\n\x16list_services_response\x18\x06 \x01(\x0b\x32\'.grpc.reflection.v1.ListServiceResponseH\x00\x12;\n\x0e\x65rror_response\x18\x07 \x01(\x0b\x32!.grpc.reflection.v1.ErrorResponseH\x00\x42\x12\n\x10message_response\"7\n\x16\x46ileDescriptorResponse\x12\x1d\n\x15\x66ile_descriptor_proto\x18\x01 \x03(\x0c\"K\n\x17\x45xtensionNumberResponse\x12\x16\n\x0e\x62\x61se_type_name\x18\x01 \x01(\t\x12\x18\n\x10\x65xtension_number\x18\x02 \x03(\x05\"K\n\x13ListServiceResponse\x12\x34\n\x07service\x18\x01 \x03(\x0b\x32#.grpc.reflection.v1.ServiceResponse\"\x1f\n\x0fServiceResponse\x12\x0c\n\x04name\x18\x01 \x01(\t\":\n\rErrorResponse\x12\x12\n\nerror_code\x18\x01 \x01(\x05\x12\x15\n\rerror_message\x18\x02 \x01(\t2\x89\x01\n\x10ServerReflection\x12u\n\x14ServerReflectionInfo\x12+.grpc.reflection.v1.ServerReflectionRequest\x1a,.grpc.reflection.v1.ServerReflectionResponse(\x01\x30\x01\x42\x66\n\x15io.grpc.reflection.v1B\x15ServerReflectionProtoP\x01Z4google.golang.org/grpc/reflection/grpc_reflection_v1b\x06proto3"

pool = Google::Protobuf::DescriptorPool.generated_pool

begin
  pool.add_serialized_file(descriptor_data)
rescue TypeError
  # Compatibility code: will be removed in the next major version.
  require 'google/protobuf/descriptor_pb'
  parsed = Google::Protobuf::FileDescriptorProto.decode(descriptor_data)
  parsed.clear_dependency
  serialized = parsed.class.encode(parsed)
  file = pool.add_serialized_file(serialized)
  warn "Warning: Protobuf detected an import path issue while loading generated file #{__FILE__}"
  imports = [
  ]
  imports.each do |type_name, expected_filename|
    import_file = pool.lookup(type_name).file_descriptor
    if import_file.name != expected_filename
      warn "- #{file.name} imports #{expected_filename}, but that import was loaded as #{import_file.name}"
    end
  end
  warn "Each proto file must use a consistent fully-qualified name."
  warn "This will become an error in the next major version."
end

module Grpc
  module Reflection
    module V1
      ServerReflectionRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("grpc.reflection.v1.ServerReflectionRequest").msgclass
      ExtensionRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("grpc.reflection.v1.ExtensionRequest").msgclass
      ServerReflectionResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("grpc.reflection.v1.ServerReflectionResponse").msgclass
      FileDescriptorResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("grpc.reflection.v1.FileDescriptorResponse").msgclass
      ExtensionNumberResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("grpc.reflection.v1.ExtensionNumberResponse").msgclass
      ListServiceResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("grpc.reflection.v1.ListServiceResponse").msgclass
      ServiceResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("grpc.reflection.v1.ServiceResponse").msgclass
      ErrorResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("grpc.reflection.v1.ErrorResponse").msgclass
    end
  end
end
