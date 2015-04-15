require "optparse"

module SensuRunCheck
  class CLI
    # Parse CLI arguments using Ruby stdlib `optparse`. This method
    # provides SensuRunCheck with process options and can
    # provide users with information, such as the SensuRunCheck version.
    #
    # @param arguments [Array] to parse.
    # @return [Hash] options
    def self.read(arguments=ARGV)
      options = {}
      optparse = OptionParser.new do |opts|
        opts.on("-h", "--help", "Display this message") do
          puts opts
          exit
        end
        opts.on("-V", "--version", "Display version") do
          puts VERSION
          exit
        end
        opts.on("-c", "--config FILE", "Sensu JSON config FILE") do |file|
          options[:config_file] = file
        end
        opts.on("-d", "--config_dir DIR[,DIR]", "DIR or comma-delimited DIR list for Sensu JSON config files") do |dir|
          options[:config_dirs] = dir.split(",")
        end
        opts.on("-e", "--extension_dir DIR", "DIR for Sensu extensions") do |dir|
          options[:extension_dir] = dir
        end
        opts.on("-r", "--run_check CHECK", "CHECK to run") do |check|
          options[:run_check] = check
        end
        opts.on("-l", "--list_checks", "List all defined checks") do
          options[:list_checks] = true
        end
        opts.on("-R", "--run_all_checks", "Run all defined checks") do
          options[:run_all_checks] = true
        end
      end
      optparse.parse!(arguments)
      options
    end
  end
end
