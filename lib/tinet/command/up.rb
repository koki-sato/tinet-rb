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
              koko_physnet("#{Tinet.namespace}-#{node.name}", interface.name)
            when :veth
              sudo "ip link add #{interface.name} type veth peer name #{interface.args}"
              koko_physnet("#{Tinet.namespace}-#{node.name}", interface.name)
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
          sudo "docker run -td --hostname #{node.name} --net=none --name #{Tinet.namespace}-#{node.name} --rm --privileged #{node.image}"
        when :netns
          sudo "ip netns add #{Tinet.namespace}-#{node.name}"
        end
      end

      # @param switch [Tinet::Switch]
      def switch_up(switch)
        sudo "ovs-vsctl add-br #{Tinet.namespace}-#{switch.name}"
        sudo "ip link set #{switch.name} up"
      end

      # @param link
      def link_up(link)
        case link.type
        when :n2n
          left_node_name = "#{Tinet.namespace}-#{link.left.node.name}"
          right_node_name = "#{Tinet.namespace}-#{link.right.node.name}"
          mount_docker_netns(left_node_name, left_node_name) if link.left.node.type == :docker
          mount_docker_netns(right_node_name, right_node_name) if link.right.node.type == :docker
          sudo "ip link add #{link.left.name} netns #{left_node_name} type veth peer name #{link.right.name} netns #{right_node_name}"
          sudo "ip netns exec #{left_node_name} ip link set #{link.left.name} up"
          sudo "ip netns exec #{right_node_name} ip link set #{link.right.name} up"
          sudo "ip netns del #{left_node_name}" if link.left.node.type == :docker
          sudo "ip netns del #{right_node_name}" if link.right.node.type == :docker
        when :s2n
          case link.right.node.type
          when :docker
            kokobr(link.left.switch.name, link.right.node.name, link.right.name)
          when :netns
            kokobr_netns(link.left.switch.name, link.right.node.name, link.right.name)
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
