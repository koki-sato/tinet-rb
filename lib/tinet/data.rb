require "yaml"
require "tinet/node"
require "tinet/switch"

module Tinet
  class Data
    class << self
      # @param yaml_path [String]
      # @return [Tinet::Data]
      def parse(yaml_path)
        yaml = YAML.load_file(yaml_path)
        raise InvalidYAMLError, "Nodes must be array" unless yaml['nodes'].is_a?(Array)
        raise InvalidYAMLError, "Switches must be array" unless yaml['switches'].is_a?(Array)

        nodes = yaml['nodes'].map { |node| Tinet::Node.parse(node) }
        switches = yaml['switches'].map { |switch| Tinet::Switch.parse(switch) }
        options = {
          precmd: fetch(yaml, 'precmd'),
          preinit: fetch(yaml, 'preinit'),
          postinit: fetch(yaml, 'postinit'),
          preconf: fetch(yaml, 'preconf'),
          postconf: fetch(yaml, 'postconf'),
          prefinish: fetch(yaml, 'prefinish'),
          postfinish: fetch(yaml, 'postfinish')
        }

        self.new(nodes, switches, options)
      end

      private

      # @param yaml [Hash]
      # @param key [String]
      # @return [Array<String>]
      def fetch(yaml, key)
        yaml.fetch(key, {}).fetch('cmds', []).map { |cmd| cmd['cmd'] || cmd }
      end
    end

    attr_reader :nodes, :switches, :options

    # @param nodes [Array<Tinet::Node>]
    # @param switches [Array<Tinet::Switch>]
    # @param options [Hash{Symbol => Array<String>}]
    def initialize(nodes, switches, options)
      @nodes = nodes
      @switches = switches
      @options = options
    end
  end
end
