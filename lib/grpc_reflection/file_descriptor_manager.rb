# frozen_string_literal: true

require "json"

module GrpcReflection
  module FileDescriptorManager
    @@proto_files = {}

    class << self
      def add(filename:, descriptor:, services:, package:)
        services.each do |s|
          converted_service = JSON.parse(s.to_json)
          @@proto_files[package + "." + converted_service["name"]] = descriptor
          converted_service["method"].each do |m|
            @@proto_files[package + "." + converted_service["name"] + "." + m["name"]] = descriptor
          end
        end
      end

      def select(name)
        [@@proto_files[name]].compact
      end
    end
  end
end
