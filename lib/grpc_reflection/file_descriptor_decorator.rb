# frozen_string_literal: true

require "json"
require "google/protobuf/descriptor_pb"

module GrpcReflection
  class FileDescriptorDecorator
    attr_reader :service_and_method_names, :descriptor_data, :filename, :dependency

    def initialize(descriptor_data)
      @file_descriptor_proto = Google::Protobuf::FileDescriptorProto.decode(descriptor_data)
      @descriptor_data = descriptor_data.b
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
