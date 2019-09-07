module Tinet
  class Link
    TYPES = %w(n2n s2n).freeze

    class << self
      # @param nodes [Array<Tinet::Node>]
      # @param switches [Array<Tinet::Switch>]
      # @return [Array<Tinet::Link>]
      def link(nodes, switches)
        link_n2n(nodes) + link_s2n(nodes, switches)
      end

      # @param nodes [Array<Tinet::Node>]
      # @return [Array<Tinet::Link>]
      def link_n2n(nodes)
        list, index = [], {}
        nodes.each do |node|
          node.interfaces.each do |interface|
            if interface.type == :direct
              key = "#{interface.args}-#{node.name}##{interface.name}"  # example: C0#net0-C1#net0
              if index.key?(key)
                list << self.new(index[key], interface, :n2n)
              else
                key = "#{node.name}##{interface.name}-#{interface.args}"  # example: C1#net0-C0#net0
                index[key] = interface
              end
            end
          end
        end
        list
      end

      # @param nodes [Array<Tinet::Node>]
      # @param switches [Array<Tinet::Switch>]
      # @return [Array<Tinet::Link>]
      def link_s2n(nodes, switches)
        list, index = [], {}
        nodes.each do |node|
          node.interfaces.each do |interface|
            key = "#{node.name}-#{interface.args}"  # example: C0-B0
            index[key] = interface if interface.type == :bridge
          end
        end
        switches.each do |switch|
          switch.interfaces.each do |interface|
            key = "#{interface.args}-#{switch.name}"  # example: C0-B0
            list << self.new(interface, index[key], :s2n) if index.key?(key)
          end
        end
        list
      end
    end

    attr_reader :left, :right, :type

    # @param left [Tinet::Node::Interfase, Tinet::Switch::Interfase]
    # @param right [Tinet::Node::Interfase]
    # @param type [Symbol]
    def initialize(left, right, type)
      @left = left
      @right = right
      @type = type
    end
  end
end
