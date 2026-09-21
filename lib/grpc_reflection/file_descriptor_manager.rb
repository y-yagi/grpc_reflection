# frozen_string_literal: true

module GrpcReflection
  module FileDescriptorManager
    @@file_descriptor_decorators = {}

    class << self
      def add(file_descriptor_proto)
        filename = file_descriptor_proto.name
        @@file_descriptor_decorators[filename] ||= GrpcReflection::FileDescriptorDecorator.new(file_descriptor_proto)
      end

      def find(name)
        file_descriptor = find_file_descriptor(name)
        return [] if file_descriptor.nil?

        collect_with_dependencies(file_descriptor)
      end

      def find_extension(containing_type, extension_number, service_names = [])
        file_descriptor = find_extension_file_descriptor(containing_type, extension_number, service_names)
        return [] if file_descriptor.nil?

        collect_with_dependencies(file_descriptor)
      end

      private

      def collect_with_dependencies(file_descriptor)
        result = {}
        result[file_descriptor.filename] = file_descriptor.serialized_file
        dependencies = file_descriptor.dependency.dup
        until dependencies.empty?
          dependency = dependencies.shift
          decorated_file_descriptor = @@file_descriptor_decorators[dependency]
          if decorated_file_descriptor.nil? && proto = Google::Protobuf::DescriptorPool.generated_pool.lookup(dependency)&.to_proto
            decorated_file_descriptor = add(proto)
          end

          if decorated_file_descriptor
            dependencies.push(*decorated_file_descriptor.dependency)
            result[decorated_file_descriptor.filename] = decorated_file_descriptor.serialized_file
          end
        end

        result.values
      end

      def find_extension_file_descriptor(containing_type, extension_number, service_names)
        candidate_file_descriptor_protos(service_names).each_value do |file_descriptor_proto|
          next unless extension_field_matches?(file_descriptor_proto, containing_type, extension_number)

          return add(file_descriptor_proto)
        end

        nil
      end

      def candidate_file_descriptor_protos(service_names)
        candidates = {}

        @@file_descriptor_decorators.each_value do |decorated_file_descriptor|
          candidates[decorated_file_descriptor.filename] = decorated_file_descriptor.file_descriptor_proto
        end

        pending = service_names.filter_map do |service_name|
          descriptor = Google::Protobuf::DescriptorPool.generated_pool.lookup(service_name)
          descriptor&.file_descriptor&.to_proto if descriptor.respond_to?(:file_descriptor)
        end

        until pending.empty?
          file_descriptor_proto = pending.shift
          next if file_descriptor_proto.nil? || candidates.key?(file_descriptor_proto.name)

          candidates[file_descriptor_proto.name] = file_descriptor_proto
          file_descriptor_proto.dependency.each do |dependency|
            next if candidates.key?(dependency)

            dependency_proto = Google::Protobuf::DescriptorPool.generated_pool.lookup(dependency)&.to_proto
            pending << dependency_proto unless dependency_proto.nil?
          end
        end

        candidates
      end

      def extension_field_matches?(file_descriptor_proto, containing_type, extension_number)
        each_extension_field(file_descriptor_proto).any? do |field|
          field.extendee == ".#{containing_type}" && field.number == extension_number
        end
      end

      def each_extension_field(file_descriptor_proto, &block)
        return enum_for(:each_extension_field, file_descriptor_proto) unless block_given?

        file_descriptor_proto.extension.each(&block)
        file_descriptor_proto.message_type.each { |message_type| each_message_extension_field(message_type, &block) }
      end

      def each_message_extension_field(message_type, &block)
        message_type.extension.each(&block)
        message_type.nested_type.each { |nested_type| each_message_extension_field(nested_type, &block) }
      end

      def find_file_descriptor(name)
        file_descriptor = @@file_descriptor_decorators.values.detect { |f| f.dataset.include?(name) }
        return file_descriptor if file_descriptor

        search_name = name
        file_descriptor_proto = nil
        loop do
          descriptor = Google::Protobuf::DescriptorPool.generated_pool.lookup(search_name)
          pos = search_name.rindex(".")
          search_name = pos ? search_name.slice(0..(pos - 1)) : nil
          unless descriptor.nil? || !descriptor.respond_to?(:file_descriptor)
            file_descriptor_proto = descriptor.file_descriptor&.to_proto
            break unless file_descriptor_proto.nil?
          end
          break if search_name.nil?
        end

        return nil if file_descriptor_proto.nil?

        add(file_descriptor_proto)
      end
    end
  end
end
