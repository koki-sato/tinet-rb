require "tinet/command/base"

module Tinet
  module Command
    class Pull < Base
      def run
        nodes.each do |node|
          unless node.image.nil?
            stdout, * = sudo "docker pull #{node.image}"
            logger.info stdout unless dry_run
          end
        end
      end
    end
  end
end
