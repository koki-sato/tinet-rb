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

        namespace = yaml.fetch('meta', {}).fetch('namespace', nil)
        Tinet.namespace = namespace unless namespace.nil? || namespace.empty?

        nodes = yaml['nodes'].map { |node| Tinet::Node.parse(node) }
        switches = yaml['switches'].map { |switch| Tinet::Switch.parse(switch) }
        options = {
          pre_cmd: fetch(yaml, 'pre_cmd'),
          pre_init: fetch(yaml, 'pre_init'),
          post_init: fetch(yaml, 'post_init'),
          pre_conf: fetch(yaml, 'pre_conf'),
          post_conf: fetch(yaml, 'post_conf'),
          pre_down: fetch(yaml, 'pre_down'),
          post_down: fetch(yaml, 'post_down')
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
