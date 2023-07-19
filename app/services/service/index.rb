# frozen_string_literal: true

module Service
  class Index < Base
    validate :ordering_by_possible

    validates(
      :ordering_direction,
      inclusion: { in: %w[ASC DESC], message: 'must be ASC or DESC' }
    )

    def initialize(ordering: {}, pagination: {}, scope: {})
      @ordering = default_ordering(ordering)
      @pagination = default_pagination(pagination)
      @scope = scope
    end

    def call
      super

      collection = all_resources
      collection = apply_order(collection)
      collection = apply_scope(collection)
      apply_pagination(collection)
    end

    protected

    def default_ordering(overloads)
      defaults = { direction: 'ASC', by: 'created_at' }
      return defaults if overloads.blank?

      defaults.merge overloads.as_json.symbolize_keys
    end

    def default_pagination(overloads)
      defaults = { page: 1 }
      return defaults if overloads.blank?

      defaults.merge overloads.as_json.symbolize_keys
    end

    def ordering_by_possible
      column = ordering[:by]
      return if column_exists?(column.to_sym)

      errors[:ordering_by] << ":#{column} is not possible, attribute does not exist on table."
    end

    def column_exists?(column)
      ActiveRecord::Base.connection.column_exists?(table_name, column)
    end

    def ordering_direction
      ordering[:direction]
    end

    attr_reader :filters, :ordering, :pagination, :scope

    def table_name
      klass.table_name
    end

    def all_resources
      raise NotImplementedError
    end

    def apply_order(selection)
      selection.order("#{ordering['by']} #{ordering['direction']}")
    end

    def apply_scope(selection)
      return selection unless scope

      selection.where(scope)
    end

    def apply_pagination(selection)
      selection.page(pagination[:page].to_i.abs)
    end
  end
end
