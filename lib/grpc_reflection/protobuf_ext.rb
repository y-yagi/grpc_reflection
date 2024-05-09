# frozen_string_literal: true
require "google/protobuf"

module GrpcReflection
  module ProtobufExt
    module DescriptorPool
      def add_serialized_file(descriptor_data)
        begin
          GrpcReflection::FileDescriptorManager.add(descriptor_data)
        rescue => e
          $stderr.puts "[grpc-reflection] parsing descriptor data is failed #{e.message}"
        end

        super
      end
    end
  end
end

Google::Protobuf::DescriptorPool.prepend(GrpcReflection::ProtobufExt::DescriptorPool)
