require "rubygems"

require "sensu-run-check/version"
require "sensu/client/process"
require "sensu/settings"

module Sensu
  # Intercepts https://github.com/sensu/sensu-spawn/blob/master/lib/sensu/spawn.rb
  module Spawn
    class << self

      # See https://github.com/sensu/sensu-spawn/blob/master/lib/sensu/spawn.rb#L22
      #
      # @param [String] command to run.
      # @param [Hash] options to create a child process with.
      # @param [Proc] IGNORED
      # @return [Array] stdout, exit code
      def process(command, options={}, &callback)
        child_process(command, options)
      end
    end
  end
end

module SensuRunCheck
  # Imposter for https://github.com/sensu/sensu/blob/master/lib/sensu/client/process.rb
  class Runner <Sensu::Client::Process

    def self.run(options={})
      s = SensuRunCheck::Runner.new(options)
      if options[:list_checks]
        puts s.get_all_checks.collect{ |check| check[:name] }.sort.join(",")
      elsif options[:run_all_checks]
        statuses = []
        s.get_all_checks.collect{ |check| check[:name] }.sort.each do |checkname|
          stdout, status = s.run_check(checkname)
          statuses << status
          puts "#{checkname} #{status} #{stdout}"
        end
        exit(statuses.max)
      else
        stdout, status = s.run_check(options[:run_check])
        puts stdout
        exit(status)
      end
    end

    # Create a new impostor.
    #
    # @param [Hash] options to create the ipostor with.
    #   At least it should contain
    #   {:config_dirs => [ "<sensu_conf_dir>" ]}
    def initialize(options={})
      @checks_in_progress = []
      @settings = Sensu::Settings.get(options)
      @settings.validate
      @logger = SensuRunCheck::NilLog.new
    end

    # Find a Sensu check by name.
    #
    # @param [String] name of the check
    # @return [Hash] check
    def get_check(checkname)
      @settings.checks.select{ |c| c[:name] == checkname }.first
    end

    # Get all Sensu checks.
    #
    # @return [Array] of checks
    def get_all_checks
      @settings.checks
    end

    # Run a Sensu check by name.
    #
    # @param [String] name of the check to run.
    # @return [Array] with stdout, exit code.
    def run_check(checkname)
      check = @settings.checks.select{ |c| c[:name] == checkname }.first
      if check == nil
        return "No such check: #{checkname}", 3
      else
        execute_check_command(check)
      end
    end

  end

  # Swallow logs
  class NilLog
    def debug(*ignore)
      # Ignore
    end
    def warn(*ignore)
      # Ignore
    end
  end
end
