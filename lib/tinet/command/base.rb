require "tinet/data"
require "tinet/link"
require "tinet/shell"

module Tinet
  module Command
    class Base
      include Shell

      def initialize(options = {})
        check_docker_installed
        @options = options
      end

      protected

      def logger
        Tinet.logger
      end

      def specfile
        @options[:specfile]
      end

      def data
        return nil if specfile.nil? || specfile.empty?
        @data ||= Tinet::Data.parse(specfile)
      end

      def nodes
        data.nodes unless data.nil?
      end

      def switches
        data.switches unless data.nil?
      end

      def links
        return nil if data.nil?
        @links ||= Tinet::Link.link(data.nodes, data.switches)
      end

      def mount_docker_netns(container, netns)
        pid, * = sudo "docker inspect #{container} -f {{.State.Pid}}"
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

      def command_exist?(command)
        _stdout, _stderr, status = sh "which #{command}", continue: true
        status.success?
      end

      def check_docker_installed
        unless command_exist?('docker')
          message = 'ERROR: Docker is not installed. TINET requires Docker.'
          logger.error(message)
          exit(1)
        end
      end
    end
  end
end
