require "tinet/data"
require "tinet/link"
require "tinet/shell"

module Tinet
  module Command
    class Base
      include Shell

      def initialize(options = {})
        @options = options
        check_docker_installed unless dry_run
        check_ovs_vsctl_installed unless dry_run
      end

      protected

      # @return [Logger]
      def logger
        Tinet.logger
      end

      # @return [String]
      def specfile
        @options.fetch(:specfile, '')
      end

      # @return [boolean]
      def dry_run
        @options.fetch('dry-run', false)
      end

      # @return [Tinet::Data, nil]
      def data
        return nil if specfile.nil? || specfile.empty?
        @data ||= Tinet::Data.parse(specfile)
      end

      # @return [Array<Tinet::Node>, nil]
      def nodes
        data.nodes unless data.nil?
      end

      # @return [Array<Tinet::Switch>, nil]
      def switches
        data.switches unless data.nil?
      end

      # @return [Array<Tinet::Link>]
      def links
        return nil if data.nil?
        @links ||= Tinet::Link.link(nodes, switches)
      end

      # @param name [String]
      # @return [String]
      def namespaced(name)
        "#{Tinet.namespace}-#{name}"
      end

      # @note Override {Tinet::Shell#sh}
      def sh(command, dry_run: dry_run(), print: true, continue: false)
        super
      end

      def mount_docker_netns(container, netns)
        if dry_run
          logger.info "PID=`sudo docker inspect #{container} -f {{.State.Pid}}`"
          pid = '$PID'
        else
          pid, * = sudo "docker inspect #{container} -f {{.State.Pid}}"
        end
        sudo 'mkdir -p /var/run/netns'
        sudo "ln -s /proc/#{pid}/ns/net /var/run/netns/#{netns}"
      end

      def exec_pre_cmd
        data.options[:pre_cmd].each { |cmd| sudo command }
      end

      def exec_pre_init
        data.options[:pre_init].each { |cmd| sudo command }
      end

      def exec_post_init
        data.options[:post_init].each { |cmd| sudo command }
      end

      def exec_pre_conf
        data.options[:pre_conf].each { |cmd| sudo command }
      end

      def exec_post_conf
        data.options[:post_conf].each { |cmd| sudo command }
      end

      def exec_pre_down
        data.options[:pre_down].each { |cmd| sudo command }
      end

      def exec_post_down
        data.options[:post_down].each { |cmd| sudo command }
      end

      private

      # @return [boolean]
      def command_exist?(command)
        *, status = sh "which #{command}", print: false, continue: true
        status.success?
      end

      def check_docker_installed
        unless command_exist?('docker')
          message = 'ERROR: Docker is not installed. TINET requires Docker.'
          logger.error(message)
          exit(1)
        end
      end

      def check_ovs_vsctl_installed
        unless command_exist?('ovs-vsctl')
          message = 'ERROR: Open vSwitch is not installed. TINET requires Open vSwitch.'
          logger.error(message)
          exit(1)
        end
      end
    end
  end
end
