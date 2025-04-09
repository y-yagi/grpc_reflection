require "grpc"
require_relative "reflection/v1alpha/reflection_v1alpha_services_pb"
require_relative 'server_shared'

class GrpcReflection::ServerAlpha < Grpc::Reflection::V1alpha::ServerReflection::Service
  include GrpcReflection::ServerShared

  def server_reflection_info(req, _unused_call)
    server_reflection_info_response(req, Grpc::Reflection::V1alpha)
  end
end
