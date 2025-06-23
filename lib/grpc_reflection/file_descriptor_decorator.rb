# frozen_string_literal: true

require "json"
require "google/protobuf/descriptor_pb"

module GrpcReflection
  class FileDescriptorDecorator
    attr_reader :service_and_method_names, :serialized_file, :filename, :dependency

    def initialize(file_descriptor_proto)
      @file_descriptor_proto = file_descriptor_proto
      @serialized_file = Google::Protobuf::FileDescriptorProto.encode(@file_descriptor_proto)
      @filename = @file_descriptor_proto.name

      @dependency = @file_descriptor_proto.dependency || []
      @service_and_method_names = {}

      set_service_and_method_names
    end

    def set_service_and_method_names
      @file_descriptor_proto.service.each do |s|
        converted_service = JSON.parse(s.to_json)
        @service_and_method_names[@file_descriptor_proto.package + "." + converted_service["name"]] = true
        converted_service["method"].each do |m|
          @service_and_method_names[@file_descriptor_proto.package + "." + converted_service["name"] + "." + m["name"]] = true
        end
      end
    end
  end
end
