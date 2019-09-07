require "thor"
require "tinet/setting"
require "tinet/command/init"
require "tinet/command/ps"

module Tinet
  class CLI < Thor
    desc 'init', 'Generate template spec file'
    def init
      Tinet::Command::Init.new.run
    end

    desc 'ps [OPTIONS]', 'List services'
    option :all, aliases: '-a', type: :boolean
    def ps
      Tinet::Command::Ps.new(options).run
    end

    desc 'version', 'Show the TINET version information'
    def version
      puts "TINET version: #{Tinet::VERSION}"
    end
  end
end
