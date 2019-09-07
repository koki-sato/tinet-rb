require "thor"
require "tinet/setting"
require "tinet/command/down"
require "tinet/command/exec"
require "tinet/command/init"
require "tinet/command/ps"
require "tinet/command/pull"
require "tinet/command/up"

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

    desc 'up [OPTIONS]', 'Create and start containers'
    option :specfile, aliases: '-f', type: :string, default: Tinet::DEFAULT_SPECFILE_PATH, desc: 'Specify specification YAML file'
    def up
      Tinet::Command::Up.new(options).run
    end

    desc 'down [OPTIONS]', 'Stop and remove containers'
    option :specfile, aliases: '-f', type: :string, default: Tinet::DEFAULT_SPECFILE_PATH, desc: 'Specify specification YAML file'
    def down
      Tinet::Command::Down.new(options).run
    end

    desc 'pull [OPTIONS]', 'Pull service images'
    option :specfile, aliases: '-f', type: :string, default: Tinet::DEFAULT_SPECFILE_PATH, desc: 'Specify specification YAML file'
    def pull
      Tinet::Command::Pull.new(options).run
    end

    desc 'exec [OPTIONS] NODE COMMAND', 'Execute a command in a running container'
    option :specfile, aliases: '-f', type: :string, default: Tinet::DEFAULT_SPECFILE_PATH, desc: 'Specify specification YAML file'
    def exec(node, command)
      Tinet::Command::Exec.new(options).run(node, command)
    end

    desc 'version', 'Show the TINET version information'
    def version
      puts "TINET version: #{Tinet::VERSION}"
    end
  end
end
