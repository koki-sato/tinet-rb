require "tinet/command/base"

module Tinet
  module Command
    class Conf < Base
      def run
        exec_pre_cmd
        exec_pre_conf

        nodes.each do |node|
          node.cmds.each do |cmd|
            case node.type
            when :docker
              sudo "docker exec #{Tinet.namespace}-#{node.name} #{cmd} > /dev/null"
            when :netns
              sudo "ip netns exec #{Tinet.namespace}-#{node.name} #{cmd} > /dev/null"
            end
          end
        end

        exec_post_conf
      end
    end
  end
end
