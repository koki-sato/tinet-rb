require "tinet/command/base"

module Tinet
  module Command
    class Up < Base
      def run
        logger.info data.to_s
      end

      private

      def all
        @options[:all]
      end
    end
  end
end
