require "logger"
require "tmpdir"

module Tinet
  class Setting
    ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
    DOCKER_PREFIX = 'tinet'.freeze
    DEFAULT_SPECFILE_PATH = './spec.yml'.freeze

    def root
      ROOT
    end

    def logger
      @logger ||= Logger.new($stderr).tap do |logger|
        logger.formatter = proc { |_sev, _dtm, _name, message| message + "\n" }
        logger.level = Logger::INFO
      end
    end

    def logger=(logger)
      @logger = logger
    end

    def pid_dir
      @pid_dir ||= Dir.tmpdir
    end

    def pid_dir=(path)
      raise "No such directory: #{path}" unless FileTest.directory?(path)
      @pid_dir = File.expand_path(path)
    end

    def log_dir
      @log_dir ||= Dir.tmpdir
    end

    def log_dir=(path)
      raise "No such directory: #{path}" unless FileTest.directory?(path)
      @log_dir = File.expand_path(path)
    end

    def socket_dir
      @socket_dir ||= Dir.tmpdir
    end

    def socket_dir=(path)
      raise "No such directory: #{path}" unless FileTest.directory?(path)
      @socket_dir = File.expand_path(path)
    end
  end

  SettingSingleton = Setting.new

  class << self
    def const_missing(name)
      Setting.const_get name
    rescue NameError
      super
    end

    def method_missing(method, *args)
      SettingSingleton.__send__ method, *args
    rescue NoMethodError
      super
    end
  end
end
