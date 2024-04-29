# frozen_string_literal: true

module GrpcReflection
  module FileDescriptorManager
    @@proto_files = {}

    class << self
      def add(filename:, descriptor:, services:, package:)
        services.each {|s| @@proto_files[package + "." + s.name] = descriptor }
      end

      def select(name)
        [@@proto_files[name]].compact
      end
    end
  end
end
