require "tinet/command/base"

module Tinet
  module Command
    class Exec < Base
      def run(node_name, command)
        node = nodes.find { |node| node.name == node_name }
        raise "No such container: #{node_name}" if node.nil?
        case node.type
        when :docker
          sudo "docker exec -it #{namespaced(node.name)} #{command}"
        when :netns
          sudo "ip netns exec #{namespaced(node.name)} #{command}"
        end
      end
    end
  end
end
