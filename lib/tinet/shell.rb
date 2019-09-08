require "open3"
require "tinet/setting"

module Tinet
  module Shell
    DummyStatus = Struct.new(:success) do |status|
      def success?
        success
      end
    end

    def sudo(command)
      sh "sudo #{command}"
    end

    def sh(command, dry_run: false, print: false, continue: false)
      if dry_run || print
        Tinet.logger.info command
      else
        Tinet.logger.debug command
      end

      return ['', '', DummyStatus.new(true)] if dry_run

      stdout, stderr, status = Open3.capture3(command)

      if !status.success? && !continue
        Tinet.logger.error "Command '#{command}' failed:"
        Tinet.logger.error "  #{stderr.chomp}" unless stderr.chomp.empty?
        exit(status.to_i)
      end

      [stdout.chomp, stderr.chomp, status]
    end
  end
end
