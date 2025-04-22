module GrpcReflection
  module ServerShared
    def server_reflection_info_response(req, proto_module)
      # TODO: support streaming call
      request = req.first

      res = proto_module::ServerReflectionResponse.new
      # TODO: implement another responses
      if request.list_services.size != 0
        res.list_services_response = proto_module::ListServiceResponse.new(service: list_services_response(proto_module))
      elsif !request.file_containing_symbol.empty?
        result = GrpcReflection::FileDescriptorManager.find(request.file_containing_symbol)
        res.file_descriptor_response = proto_module::FileDescriptorResponse.new(file_descriptor_proto: result)
      end
      [res].enum_for(:each)
    end

    private

    def main_server
      @main_server ||= ObjectSpace.each_object(GRPC::RpcServer).to_a[0]
    end

    def service_names
      @service_names ||= main_server.send(:rpc_descs).keys.map { |k| k.to_s.split('/')[1] }.uniq
    end

    def list_services_response(proto_module)
      @list_services_response ||= service_names.map {|name| proto_module::ServiceResponse.new(name: name) }
    end

  end
end
