# frozen_string_literal: true

module Service
  module Errors
    class Invalid < StandardError
      def initialize(resource)
        super resource.errors.full_messages.inspect
      end
    end
  end
end
