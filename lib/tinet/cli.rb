require "thor"
require "tinet/setting"
require "tinet/command/build"
require "tinet/command/conf"
require "tinet/command/down"
require "tinet/command/exec"
require "tinet/command/init"
require "tinet/command/ps"
require "tinet/command/pull"
require "tinet/command/up"

module Tinet
  class CLI < Thor
    map %w[--version -v] => :version

    desc 'init', 'Generate template spec file'
    option :version, aliases: '-v', type: :boolean, default: false, desc: 'Show the TINET version information'
    def init
      return version if options[:version]
      Tinet::Command::Init.new.run
    end

    desc 'ps [OPTIONS]', 'List services'
    option :all, aliases: '-a', type: :boolean, desc: 'Show all containers (default shows just running)'
    option 'dry-run', aliases: '-d', type: :boolean, default: false, desc: 'Print the recipes that are needed to execute'
    option :version, aliases: '-v', type: :boolean, default: false, desc: 'Show the TINET version information'
    def ps
      return version if options[:version]
      Tinet::Command::Ps.new(options).run
    end

    desc 'up [OPTIONS]', 'Create and start containers'
    option :specfile, aliases: '-f', type: :string, default: Tinet::DEFAULT_SPECFILE_PATH, desc: 'Specify specification YAML file'
    option 'dry-run', aliases: '-d', type: :boolean, default: false, desc: 'Print the recipes that are needed to execute'
    option :version, aliases: '-v', type: :boolean, default: false, desc: 'Show the TINET version information'
    def up
      return version if options[:version]
      Tinet::Command::Up.new(options).run
      Tinet::Command::Conf.new(options).run
    end

    desc 'down [OPTIONS]', 'Stop and remove containers'
    option :specfile, aliases: '-f', type: :string, default: Tinet::DEFAULT_SPECFILE_PATH, desc: 'Specify specification YAML file'
    option 'dry-run', aliases: '-d', type: :boolean, default: false, desc: 'Print the recipes that are needed to execute'
    option :version, aliases: '-v', type: :boolean, default: false, desc: 'Show the TINET version information'
    def down
      return version if options[:version]
      Tinet::Command::Down.new(options).run
    end

    desc 'pull [OPTIONS]', 'Pull service images'
    option :specfile, aliases: '-f', type: :string, default: Tinet::DEFAULT_SPECFILE_PATH, desc: 'Specify specification YAML file'
    option 'dry-run', aliases: '-d', type: :boolean, default: false, desc: 'Print the recipes that are needed to execute'
    option :version, aliases: '-v', type: :boolean, default: false, desc: 'Show the TINET version information'
    def pull
      return version if options[:version]
      Tinet::Command::Pull.new(options).run
    end

    desc 'exec [OPTIONS] NODE COMMAND', 'Execute a command in a running container'
    option :specfile, aliases: '-f', type: :string, default: Tinet::DEFAULT_SPECFILE_PATH, desc: 'Specify specification YAML file'
    option 'dry-run', aliases: '-d', type: :boolean, default: false, desc: 'Print the recipes that are needed to execute'
    option :version, aliases: '-v', type: :boolean, default: false, desc: 'Show the TINET version information'
    def exec(node, command)
      return version if options[:version]
      Tinet::Command::Exec.new(options).run(node, command)
    end

    desc 'build [OPTIONS]', 'Build Docker images from the spec file'
    option :specfile, aliases: '-f', type: :string, default: Tinet::DEFAULT_SPECFILE_PATH, desc: 'Specify specification YAML file'
    option 'dry-run', aliases: '-d', type: :boolean, default: false, desc: 'Print the recipes that are needed to execute'
    option :version, aliases: '-v', type: :boolean, default: false, desc: 'Show the TINET version information'
    def build
      return version if options[:version]
      Tinet::Command::Build.new(options).run
    end

    desc 'conf [OPTIONS]', 'Execute commands in a running container'
    option :specfile, aliases: '-f', type: :string, default: Tinet::DEFAULT_SPECFILE_PATH, desc: 'Specify specification YAML file'
    option 'dry-run', aliases: '-d', type: :boolean, default: false, desc: 'Print the recipes that are needed to execute'
    option :version, aliases: '-v', type: :boolean, default: false, desc: 'Show the TINET version information'
    def conf
      return version if options[:version]
      Tinet::Command::Conf.new(options).run
    end

    desc 'restart [OPTIONS]', 'Down and Up running containers'
    option :specfile, aliases: '-f', type: :string, default: Tinet::DEFAULT_SPECFILE_PATH, desc: 'Specify specification YAML file'
    option 'dry-run', aliases: '-d', type: :boolean, default: false, desc: 'Print the recipes that are needed to execute'
    option :version, aliases: '-v', type: :boolean, default: false, desc: 'Show the TINET version information'
    def restart
      return version if options[:version]
      Tinet::Command::Down.new(options).run
      Tinet::Command::Up.new(options).run
    end

    desc 'version', 'Show the TINET version information'
    def version
      puts "TINET version: #{Tinet::VERSION}"
    end

    # @note Override {Thor#help}
    def help(command = nil, subcommand = false)
      if command.nil?
        puts <<-USAGE
Usage:
  tinet [OPTIONS] COMMAND

Options:
  -f, [--specfile=SPECFILE]  # Specify specification YAML file (Default: ./spec.yml)
  -d, [--dry-run]            # Print the recipes that are needed to execute
  -v, [--version]            # Show the TINET version information

USAGE
      end
      super
    end
  end
end
