require "grpc"
require_relative "reflection/v1/reflection_services_pb"
require_relative 'server_shared'

class GrpcReflection::Server < Grpc::Reflection::V1::ServerReflection::Service
  include GrpcReflection::ServerShared

  def server_reflection_info(req, _unused_call)
    server_reflection_info_response(req, Grpc::Reflection::V1)
  end
end
