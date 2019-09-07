require "thor"
require "tinet/setting"
require "tinet/command/ps"

module Tinet
  class CLI < Thor
    desc 'ps [OPTIONS]', 'List services'
    option :all, type: :boolean, aliases: '-a'
    def ps
      Tinet::Command::Ps.new(options).run
    end

    desc 'version', 'Show the TINET version information'
    def version
      puts "TINET version: #{Tinet::VERSION}"
    end
  end
end
