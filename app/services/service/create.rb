# frozen_string_literal: true

module Service
  class Create < Base
    attr_reader :model

    def allowed_attributes
      raise NotImplementedError
    end

    def call
      super

      @model = build
      model.update!(permitted_attributes)

      model
    end
  end
end
