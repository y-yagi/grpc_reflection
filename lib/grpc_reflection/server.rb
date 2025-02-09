require "grpc"
require_relative "reflection/v1/reflection_services_pb"

class GrpcReflection::Server < Grpc::Reflection::V1::ServerReflection::Service
  def server_reflection_info(req, _unused_call)
    # TODO: support streaming call
    request = req.first

    res = Grpc::Reflection::V1::ServerReflectionResponse.new
    # TODO: implement another responses
    if request.list_services.size != 0
      res.list_services_response = Grpc::Reflection::V1::ListServiceResponse.new(service: list_services_response)
    elsif !request.file_containing_symbol.empty?
      result = GrpcReflection::FileDescriptorManager.find(request.file_containing_symbol)
      res.file_descriptor_response = Grpc::Reflection::V1::FileDescriptorResponse.new(file_descriptor_proto: result)
    end
    [res].enum_for(:each)
  end

  private

  def service_names
    @service_names ||= ObjectSpace.each_object(Class).filter_map {|k| k if k.ancestors.include?(GRPC::GenericService) }.map do |proto_servie|
      proto_servie.service_name
    end.uniq
  end

  def list_services_response
    @list_services_response ||= service_names.map {|name| Grpc::Reflection::V1::ServiceResponse.new(name: name) }
  end
end
