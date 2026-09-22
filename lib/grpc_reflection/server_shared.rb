module GrpcReflection
  module ServerShared
    def server_reflection_info_response(req, proto_module)
      req.lazy.map { |request| build_response(request, proto_module) }
    end

    private

    def build_response(request, proto_module)
      res = proto_module::ServerReflectionResponse.new(original_request: request, valid_host: request.host)
      case request.message_request
      when :list_services
        res.list_services_response = proto_module::ListServiceResponse.new(service: list_services_response(proto_module))
      when :file_containing_symbol
        result = GrpcReflection::FileDescriptorManager.find(request.file_containing_symbol)
        if result.empty?
          res.error_response = error_response(proto_module, GRPC::Core::StatusCodes::NOT_FOUND, "symbol not found: #{request.file_containing_symbol}")
        else
          res.file_descriptor_response = proto_module::FileDescriptorResponse.new(file_descriptor_proto: result)
        end
      when :file_by_filename
        descriptor = Google::Protobuf::DescriptorPool.generated_pool.lookup(request.file_by_filename)
        if !descriptor.is_a?(Google::Protobuf::FileDescriptor)
          res.error_response = error_response(proto_module, GRPC::Core::StatusCodes::NOT_FOUND, "file not found: #{request.file_by_filename}")
        else
          res.file_descriptor_response = proto_module::FileDescriptorResponse.new(file_descriptor_proto: [Google::Protobuf::FileDescriptorProto.encode(descriptor.to_proto)])
        end
      when :file_containing_extension
        result = GrpcReflection::FileDescriptorManager.find_extension(
          request.file_containing_extension.containing_type,
          request.file_containing_extension.extension_number,
          service_names
        )
        if result.empty?
          res.error_response = error_response(proto_module, GRPC::Core::StatusCodes::NOT_FOUND, "extension not found: #{request.file_containing_extension.containing_type} #{request.file_containing_extension.extension_number}")
        else
          res.file_descriptor_response = proto_module::FileDescriptorResponse.new(file_descriptor_proto: result)
        end
      when :all_extension_numbers_of_type
        res.error_response = error_response(proto_module, GRPC::Core::StatusCodes::UNIMPLEMENTED, "all_extension_numbers_of_type is not implemented")
      else
        res.error_response = error_response(proto_module, GRPC::Core::StatusCodes::INVALID_ARGUMENT, "invalid MessageRequest")
      end
      res
    end

    def error_response(proto_module, error_code, error_message)
      proto_module::ErrorResponse.new(error_code: error_code, error_message: error_message)
    end

    def main_server
      @main_server ||= ObjectSpace.each_object(GRPC::RpcServer).find do |server|
        server.send(:rpc_handlers).values.any? { |handler| handler.receiver.equal?(self) }
      end
    end

    def service_names
      @service_names ||= main_server.send(:rpc_descs).keys.map { |k| k.to_s.split('/')[1] }.uniq
    end

    def list_services_response(proto_module)
      @list_services_response ||= service_names.map {|name| proto_module::ServiceResponse.new(name: name) }
    end

  end
end
