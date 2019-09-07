require "logger"

module Tinet
  class Setting
    ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
    DEFAULT_SPECFILE_PATH = './spec.yml'.freeze

    # @return [String]
    def root
      ROOT
    end

    # @return [String]
    def namespace
      @namespace ||= 'tinet'
    end

    # @param namespace [String]
    # @return [String]
    def namespace=(namespace)
      @namespace = namespace
    end

    # @return [Logger]
    def logger
      @logger ||= Logger.new($stderr).tap do |logger|
        logger.formatter = proc { |_sev, _dtm, _name, message| message + "\n" }
        logger.level = Logger::INFO
      end
    end

    # @param logger [Logger]
    # @return [Logger]
    def logger=(logger)
      @logger = logger
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
