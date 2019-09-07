require "tinet/command/base"

module Tinet
  module Command
    class Down < Base
      def run
        exec_pre_cmd
        exec_pre_down

        nodes.each do |node|
          node.interfaces.each do |interface|
            if interface.type == :phys
              detach_physnet_from_docker("#{Tinet.namespace}-#{node.name}", interface.name)
            end
          end
        end

        nodes.each do |node|
          case node.type
          when :docker
            sudo "docker stop #{Tinet.namespace}-#{node.name}"
          when :netns
            sudo "ip netns del #{Tinet.namespace}-#{node.name}"
          end
        end

        switches.each do |switch|
          sudo "ovs-vsctl del-br #{Tinet.namespace}-#{switch.name}"
        end

        exec_post_down
      end

      private

      def detach_physnet_from_docker(container, ifname)
        mount_docker_netns(container, container)
        sudo "ip netns exec #{container} ip link set #{ifname} netns 1"
        sudo "ip netns del #{container}"
      end
    end
  end
end
