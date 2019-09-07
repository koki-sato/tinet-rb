module Tinet
  class Switch
    # @param switch_hash [Hash]
    # @return [Tinet::Switch]
    def self.parse(switch_hash)
      name, interfaces = switch_hash['name'], switch_hash['interfaces']
      raise InvalidYAMLError, "Switch name is missing" if name.nil? || name.empty?
      raise InvalidYAMLError, "Switch interfaces must be array" unless interfaces.is_a?(Array)

      interfaces = interfaces.map { |interface| Interfase.parse(interface) }
      self.new(name, interfaces)
    end

    attr_reader :name, :interfaces

    # @param name [String]
    # @param interfaces [Array<Tinet::Switch::Interfase>]
    def initialize(name, interfaces)
      @name = name
      @interfaces = interfaces
    end

    class Interfase
      TYPES = %w(docker netns phys).freeze

      # @param interface_hash [Hash]
      # @return [Tinet::Switch::Interfase]
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
