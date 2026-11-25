# frozen_string_literal: true

class PrComet
  module Errors
    # Common error class
    class Error < StandardError; end

    # Git origin is not a supported GitHub repository URL
    class InvalidRemoteUrl < Error; end

    # Un-commited modify was detected on the local
    class ExistUncommittedModify < Error; end
  end
end
