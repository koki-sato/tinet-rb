require "tinet/command/base"

module Tinet
  module Command
    class Up < Base
      def run
        exec_pre_cmd
        exec_pre_init

        # Create Nodes and Switches
        nodes.each { |node| node_up(node) }
        switches.each { |switch| switch_up(switch) }

        # Create Links
        links.each { |link| link_up(link) }

        # Attach physnet / veth to Conitaner
        nodes.each do |node|
          node.interfaces.each do |interface|
            case interface.type
            when :phys
              koko_physnet("#{namespaced(node.name)}", interface.name)
            when :veth
              sudo "ip link add #{interface.name} type veth peer name #{interface.args}"
              koko_physnet("#{namespaced(node.name)}", interface.name)
              sudo "ip link set #{interface.args} up"
            end
          end
        end

        exec_post_init
      end

      private

      def all
        @options[:all]
      end

      # @param node [Tinet::Node]
      def node_up(node)
        case node.type
        when :docker
          sudo "docker run -td --hostname #{node.name} --net=none --name #{namespaced(node.name)} --rm --privileged #{node.image}"
        when :netns
          sudo "ip netns add #{namespaced(node.name)}"
        end
      end

      # @param switch [Tinet::Switch]
      def switch_up(switch)
        sudo "ovs-vsctl add-br #{namespaced(switch.name)}"
        sudo "ip link set #{namespaced(switch.name)} up"
      end

      # @param link [Tinet::Link]
      def link_up(link)
        left, right = link.left, link.right
        case link.type
        when :n2n
          mount_docker_netns(namespaced(left.node.name), namespaced(left.node.name)) if left.node.type == :docker
          mount_docker_netns(namespaced(right.node.name), namespaced(right.node.name)) if right.node.type == :docker
          sudo "ip link add #{left.name} netns #{namespaced(left.node.name)} type veth peer name #{right.name} netns #{namespaced(right.node.name)}"
          sudo "ip netns exec #{namespaced(left.node.name)} ip link set #{left.name} up"
          sudo "ip netns exec #{namespaced(right.node.name)} ip link set #{right.name} up"
          sudo "ip netns del #{namespaced(left.node.name)}" if left.node.type == :docker
          sudo "ip netns del #{namespaced(right.node.name)}" if right.node.type == :docker
        when :s2n
          case right.node.type
          when :docker
            kokobr(namespaced(left.switch.name), namespaced(right.node.name), right.name)
          when :netns
            kokobr_netns(namespaced(left.switch.name), namespaced(right.node.name), right.name)
          end
        end
      end

      def kokobr(bridge, container, ifname)
        mount_docker_netns(container, container)
        sudo "ip link add name #{ifname} type veth peer name #{container}-#{ifname}"
        sudo "ip link set dev #{ifname} netns #{container}"
        sudo "ip link set #{container}-#{ifname} up"
        sudo "ip netns exec #{container} ip link set #{ifname} up"
        sudo "ip netns del #{container}"
        sudo "ovs-vsctl add-port #{bridge} #{container}-#{ifname}"
      end

      def kokobr_netns(bridge, container, ifname)
        sudo "ip link add name #{ifname} type veth peer name #{container}-#{ifname}"
        sudo "ip link set dev #{ifname} netns #{container}"
        sudo "ip link set #{container}-#{ifname} up"
        sudo "ip netns exec #{container} ip link set #{ifname} up"
        sudo "ovs-vsctl add-port #{bridge} #{container}-#{ifname}"
      end

      def koko_physnet(container, netif)
        mount_docker_netns(container, container)
        sudo "ip link set dev #{netif} netns #{container}"
        sudo "ip netns exec #{container} ip link set #{netif} up"
        sudo "ip netns del #{container}"
      end
    end
  end
end
