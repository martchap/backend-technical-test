# frozen_string_literal: true

module Service
  class Base
    include ActiveModel::Validations

    def initialize(attributes: {})
      @attributes = ActiveSupport::HashWithIndifferentAccess.new(attributes.permit!.dup) if attributes
    end

    def self.call(args)
      new(**args).call
    end

    def call
      raise(Errors::Invalid, self) unless valid?
    end

    protected

    def klass_name
      class_path = self.class.name.split('::')
      self_class = class_path.select { |clss| clss.include? 'Service' }.last
      self_class.sub('Service', '').singularize
    end

    def klass
      Object.const_get(klass_name, false)
    end

    attr_reader :attributes

    def merge_attributes(to_append)
      attributes.merge! to_append
    end

    def build
      klass.new permitted_attributes
    end

    def permitted_attributes
      # Do the .to_hash incase were passed in ActionController::Parameters
      attributes.to_hash.symbolize_keys!.slice(*allowed_attributes)
    end

    def respond_to_missing?(name, _include_private)
      attribute?(name)
    end

    def attribute?(name)
      attributes.key?(name) || allowed_attributes.include?(name)
    end

    def method_missing(name)
      return attributes[name] if attribute?(name)

      super
    end
  end
end
