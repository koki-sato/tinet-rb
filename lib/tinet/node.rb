module Tinet
  class Node
    TYPES = %w(docker netns).freeze

    # @param node_hash [Hash]
    # @return [Tinet::Node]
    def self.parse(node_hash)
      name, type, interfaces = node_hash['name'], node_hash['type'], node_hash['interfaces']
      raise InvalidYAMLError, "Node name is missing" if name.nil? || name.empty?
      raise InvalidTypeError, "Unknown node type: #{type}" unless TYPES.include?(type)
      raise InvalidYAMLError, "Node interfaces must be array" unless interfaces.is_a?(Array)

      interfaces = interfaces.map { |interface| Interfase.parse(interface) }
      cmds = node_hash.fetch('cmds', []).map { |cmd| cmd['cmd'] || cmd }
      self.new(name, type, node_hash['image'], node_hash['build'], interfaces, cmds)
    end

    attr_reader :name, :type, :image, :build, :interfaces, :cmds

    # @param name [String]
    # @param type [Symbol]
    # @param image [String, nil]
    # @param build [String, nil]
    # @param interfaces [Array<Tinet::Node::Interfase>]
    # @param cmds [Array<String>]
    def initialize(name, type, image, build, interfaces, cmds)
      @name = name
      @type = type
      @image = image
      @build = build
      @interfaces = interfaces
      @cmds = cmds
    end

    class Interfase
      TYPES = %w(direct bridge veth phys).freeze

      # @param interface_hash [Hash]
      # @return [Tinet::Node::Interfase]
      def self.parse(interface_hash)
        name, type, args = interface_hash['name'], interface_hash['type'], interface_hash['args']
        raise InvalidYAMLError, "Interfase name is missing" if name.nil? || name.empty?
        raise InvalidTypeError, "Unknown interface type: #{type}" unless TYPES.include?(type)
        self.new(name, type.to_sym, args)
      end

      attr_reader :name, :type, :args

      # @param name [String]
      # @param type [Symbol]
      # @param args [String, nil]
      def initialize(name, type, args)
        @name = name
        @type = type.to_sym
        @args = args
      end
    end
  end
end
