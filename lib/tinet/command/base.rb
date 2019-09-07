module Tinet
  module Command
    class Base
      include Shell

      def initialize(options = {})
        check_docker_installed
        @options = options
      end

      protected

      def logger
        Tinet.logger
      end

      private

      def command_exist?(command)
        _stdout, _stderr, status = sh "which #{command}", continue: true
        status.success?
      end

      def check_docker_installed
        unless command_exist?('docker')
          message = 'ERROR: Docker is not installed. TINET requires Docker.'
          logger.error(message)
          exit(1)
        end
      end
    end
  end
end
