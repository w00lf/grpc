require 'logging'

# GRPC is the general RPC module
#
# Configure its logging for fine-grained log control during test runs
module GRPC
  extend Logging.globally
end

Logging.logger.root.appenders = Logging.appenders.stdout
Logging.logger.root.level = :debug
Logging.logger['GRPC'].level = :debug
Logging.logger['GRPC::ActiveCall'].level = :debug
Logging.logger['GRPC::BidiCall'].level = :debug
