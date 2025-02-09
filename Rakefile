# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"
require "tmpdir"
require "fileutils"

Minitest::TestTask.create do |t|
  t.verbose = true
end

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
