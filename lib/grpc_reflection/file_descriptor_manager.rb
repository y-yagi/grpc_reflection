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
        return [] if file_descriptor.nil?

        result = {}
        result[file_descriptor.filename] = file_descriptor.descriptor_data
        dependencies = file_descriptor.dependency.dup
        until dependencies.empty?
          dependency = dependencies.shift
          dependent_file_descriptor = @@file_descriptors.detect { |f| f.filename == dependency }
          dependencies.push(*dependent_file_descriptor.dependency)
          result[dependent_file_descriptor.filename] = dependent_file_descriptor.descriptor_data
        end

       result.values
      end
    end
  end
end
