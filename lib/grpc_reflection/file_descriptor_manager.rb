# frozen_string_literal: true

module GrpcReflection
  module FileDescriptorManager
    @@file_descriptors = []

    class << self
      def add(descriptor)
        @@file_descriptors << GrpcReflection::FileDescriptor.new(descriptor)
      end

      def select(name)
        file_descriptor = @@file_descriptors.detect { |f| f.service_and_method_names[name] }
        [file_descriptor&.descriptor_data].compact
      end
    end
  end
end
