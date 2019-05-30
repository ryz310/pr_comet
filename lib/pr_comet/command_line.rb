# frozen_string_literal: true

class PrComet
  # To execute command line. You should inherit this class to use.
  module CommandLine
    private

    # Execute a command
    #
    # @param command [String] The command you want to execute
    # @return [String] The result in the execution
    def execute(command)
      puts "$ #{command}"
      `#{command}`.chomp.tap do |result|
        color = $CHILD_STATUS.success? ? :green : :red
        puts Rainbow(result).color(color)
      end
    end
  end
end
