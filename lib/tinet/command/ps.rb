require "tinet/command/base"

module Tinet
  module Command
    class Ps < Base
      def run
        if all
          command = "docker ps -a -f name=#{Tinet.namespace}"
        else
          command = "docker ps -f name=#{Tinet.namespace}"
        end
        stdout, _stderr, _status = sudo command
        unless dry_run
          logger.info 'TINET Docker Containers'
          logger.info '-' * 50
          logger.info stdout
        end
      end

      private

      def all
        @options[:all]
      end
    end
  end
end
