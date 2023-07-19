# frozen_string_literal: true

module Service
  class Update < Create
    def initialize(find_by:, attributes:, scope: nil)
      super(attributes: attributes)

      @find_by = find_by
    end

    def model
      @model ||= klass.find_by!(find_by)
    end

    protected

    attr_reader :find_by

    def build
      model
    end
  end
end
