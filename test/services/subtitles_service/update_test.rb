require 'test_helper'

class Update < ActiveSupport::TestCase
  setup do
    @subtitle = subtitles(:one)
    @file = Rack::Test::UploadedFile.new(File.open("/Users/martinchapman/repos/backend-technical-test/test/fixtures/files/pulp-fiction.srt"))
    @invalid_file = Rack::Test::UploadedFile.new(File.open("/Users/martinchapman/repos/backend-technical-test/test/fixtures/files/invalid.srt"))
    @valid_params = ActionController::Parameters.new(file: @file)
    @invalid_params = ActionController::Parameters.new(file: @invalid_file)
  end

  test 'updates a subtitle' do
    SubtitlesService::Update.call(attributes: @valid_params, find_by: { id: @subtitle.id })
    assert_not_nil @subtitle.reload.body
  end

  test 'raises errors when file invalid' do
    e = assert_raises Service::Errors::Invalid do
      SubtitlesService::Update.call(attributes: @invalid_params, find_by: { id: @subtitle.id })
    end

    assert_equal ["Cue#2 has a non-incrementing timecode"], JSON.parse(e.message)
  end
end