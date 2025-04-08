# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"
require "tmpdir"
require "fileutils"

Minitest::TestTask.create do |t|
  t.verbose = true
end

# For this task to work, you need to have the reflection protos in a directory. You can find these
# here: https://github.com/grpc/grpc/tree/master/src/proto/grpc/reflection
# Add folders `v1` and `v1alpha` as shown in the tree above, then set `PROTO_DIR` to that
# directory and you can then run this task.
# Please note that the already-generated code likely does not need to be re-generated
# since these protos are extremely unlikely to change, so this task most likely does not
# need to be run.
task :update_code_generated_by_protoc do
  proto_dir = ENV.fetch("PROTO_DIR")
  Dir.chdir(proto_dir) do
    system("bundle exec grpc_tools_ruby_protoc --ruby_out=./  --grpc_out=./ reflection.proto", exception: true)
  end

  service_file = "lib/grpc_reflection/reflection/v1/reflection_services_pb.rb"
  FileUtils.mv("#{proto_dir}/reflection_services_pb.rb", service_file, force: true)
  FileUtils.mv("#{proto_dir}/reflection_pb.rb", "lib/grpc_reflection/reflection/v1/reflection_pb.rb", force: true)

  File.write(service_file, File.read(service_file).gsub(/require 'reflection_pb'/, "require_relative 'reflection_pb'"))
end

task default: :test
