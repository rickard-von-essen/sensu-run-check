require "rubygems"

require "open3"
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
          status ||= 3
          statuses << status
          puts "#{checkname} #{status} #{stdout}"
        end
        exit(statuses.max)
      else
        stdout, status = s.run_check(options[:run_check])
        puts stdout
        status ||= 3
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

    # Execute a check command, capturing its output (STDOUT/ERR),
    # exit status code, execution duration, timestamp, and publish
    # the result. This method guards against multiple executions for
    # the same check. Check command tokens are substituted with the
    # associated client attribute values. If there are unmatched
    # check command tokens, the check command will not be executed,
    # instead a check result will be published reporting the
    # unmatched tokens.
    #
    # @param check [Hash]
    def execute_check_command(check)
      @logger.debug("attempting to execute check command", :check => check)
      unless @checks_in_progress.include?(check[:name])
        @checks_in_progress << check[:name]
        command, unmatched_tokens = substitute_check_command_tokens(check)
        if unmatched_tokens.empty?
          check[:executed] = Time.now.to_i
          started = Time.now.to_f

          output, status = Open3.capture2(command)
          check[:duration] = ("%.3f" % (Time.now.to_f - started)).to_f
          check[:output] = output
          check[:status] = status.exitstatus
          @checks_in_progress.delete(check[:name])
          publish_check_result(check)
        else
          check[:output] = "Unmatched command tokens: " + unmatched_tokens.join(", ")
          check[:status] = 3
          check[:handle] = false
          @checks_in_progress.delete(check[:name])
          publish_check_result(check)
        end
      else
        @logger.warn("previous check command execution in progress", :check => check)
      end
    end

    def publish_check_result(check)
      return check[:output], check[:status]
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
    def initialize
      self.class.create_level_methods
    end

    def self.create_level_methods
      Sensu::Logger::LEVELS.each do |level|
        define_method(level) do |*args|
          # Do nothing
        end
      end
    end
  end
end
