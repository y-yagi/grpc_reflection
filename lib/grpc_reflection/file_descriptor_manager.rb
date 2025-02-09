# frozen_string_literal: true

module GrpcReflection
  module FileDescriptorManager
    @@file_descriptor_decorators = []

    class << self
      def add(file_descriptor_proto)
        @@file_descriptor_decorators << GrpcReflection::FileDescriptorDecorator.new(file_descriptor_proto)
      end

      def find(name)
        file_descriptor = find_file_descriptor(name)
        return [] if file_descriptor.nil?

        result = {}
        result[file_descriptor.filename] = file_descriptor.serialized_file
        dependencies = file_descriptor.dependency.dup
        until dependencies.empty?
          dependency = dependencies.shift
          dependent_file_descriptor = @@file_descriptor_decorators.detect { |f| f.filename == dependency }
          if dependent_file_descriptor
            dependencies.push(*dependent_file_descriptor.dependency)
            result[dependent_file_descriptor.filename] = dependent_file_descriptor.descriptor_data
          end
        end

        result.values
      end

      private

      def find_file_descriptor(name)
        file_descriptor = @@file_descriptor_decorators.detect { |f| f.service_and_method_names[name] }
        return file_descriptor if file_descriptor

        search_name = name
        file_descriptor_proto = nil
        while pos = search_name.rindex(".")
          file_descriptor_proto = Google::Protobuf::DescriptorPool.generated_pool.lookup(search_name)&.file_descriptor&.to_proto
          break unless file_descriptor_proto.nil?
          search_name = search_name.slice(0..(pos - 1))
        end

        return nil if file_descriptor_proto.nil?

        add(file_descriptor_proto)
        @@file_descriptor_decorators.detect { |f| f.service_and_method_names[name] }
      end
    end
  end
end
