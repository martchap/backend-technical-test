# frozen_string_literal: true

module SubtitlesService
  class Index < Service::Index
    def all_resources
      Subtitle.all
    end
  end
end
