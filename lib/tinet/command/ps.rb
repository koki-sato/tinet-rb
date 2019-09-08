require "tinet/command/base"

module Tinet
  module Command
    class Ps < Base
      def run
        if all
          stdout, * = sudo "docker ps -a -f name=#{Tinet.namespace}"
        else
          stdout, * = sudo "docker ps -f name=#{Tinet.namespace}"
        end

        unless dry_run
          logger.info 'TINET Docker Containers'
          logger.info '-' * 50
          logger.info stdout
        end
      end

      private

      # @return [boolean]
      def all
        @options[:all]
      end
    end
  end
end
