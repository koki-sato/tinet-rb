require "fileutils"
require "tinet/setting"
require "tinet/shell"
require "tinet/command/base"

module Tinet
  module Command
    class Init < Base
      def run
        template = File.join(Tinet::ROOT, 'spec.template.yml')
        specfile = Tinet::DEFAULT_SPECFILE_PATH
        FileUtils.cp(template, specfile)
        logger.info 'Initialized. Check spec.yml'
      end

      private

      def all
        @options[:all]
      end
    end
  end
end
