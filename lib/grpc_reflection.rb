# frozen_string_literal: true

TracePoint.new(:c_call) do |tp|
  puts "hi" if "#{tp.defined_class}.#{tp.method_id}" == "Google::Protobuf::DescriptorPool.add_serialized_file"
end.enable

require_relative "grpc_reflection/version"
require_relative "grpc_reflection/file_descriptor_decorator"
require_relative "grpc_reflection/file_descriptor_manager"
require_relative "grpc_reflection/server"

module GrpcReflection; end
