# frozen_string_literal: true

module Service
  class New < Base
    def allowed_attributes
      []
    end

    def call
      super

      @model = klass.new(permitted_attributes)
    end
  end
end
