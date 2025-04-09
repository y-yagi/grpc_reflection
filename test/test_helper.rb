# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
$LOAD_PATH.unshift File.expand_path("protos", __dir__)

require "debug"
require "grpc_reflection"
require "minitest/hooks/test"
require "minitest/autorun"
