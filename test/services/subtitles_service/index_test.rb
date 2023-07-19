require 'test_helper'

class Index < ActiveSupport::TestCase
  setup do
    @subtitles = Subtitle.all
  end

  test 'returns all subtitles' do
    assert_equal @subtitles.count, SubtitlesService::Index.call(
      pagination: { page: 1 },
      ordering: { by: :created_at, direction: 'DESC' }
    ).count
  end
end