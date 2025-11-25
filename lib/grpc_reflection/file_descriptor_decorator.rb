# frozen_string_literal: true

require "json"
require "set"
require "google/protobuf/descriptor_pb"

module GrpcReflection
  class FileDescriptorDecorator
    attr_reader :dataset, :serialized_file, :filename, :dependency

    def initialize(file_descriptor_proto)
      @file_descriptor_proto = file_descriptor_proto
      @serialized_file = Google::Protobuf::FileDescriptorProto.encode(@file_descriptor_proto)
      @filename = @file_descriptor_proto.name

      @dependency = @file_descriptor_proto.dependency || []
      @dataset = Set.new

      set_dataset
    end

    private

    def set_dataset
      @file_descriptor_proto.service.each do |s|
        converted_service = JSON.parse(s.to_json)
        @dataset.add(@file_descriptor_proto.package + "." + converted_service["name"])
        converted_service["method"].each do |m|
          @dataset.add(@file_descriptor_proto.package + "." + converted_service["name"] + "." + m["name"])
          @dataset.add(m["inputType"][1..])
          @dataset.add(m["outputType"][1..])
        end
      end
    end
  end
end
