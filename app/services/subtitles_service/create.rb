# frozen_string_literal: true

require "subtitle_validator"

module SubtitlesService
  class Create < Service::Create
    validates :filename, presence: true
    validates :body, presence: true
    validate :srt_content

    def initialize(attributes: {})
      super(attributes: attributes)

      merge_attributes(filename: filename, body: body)
    end

    def allowed_attributes
      %i[filename body]
    end

    private

    def srt_content
      SubtitleValidator.new(body).errors.each do |error|
        errors.add(:base, error)
      end
    end

    def body
      File.read(file.path)
    end

    def filename
      file.original_filename
    end
  end
end
