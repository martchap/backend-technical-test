require 'test_helper'

class Create < ActiveSupport::TestCase
  setup do
    @file = Rack::Test::UploadedFile.new(File.open("/Users/martinchapman/repos/backend-technical-test/test/fixtures/files/pulp-fiction.srt"))
    @invalid_file = Rack::Test::UploadedFile.new(File.open("/Users/martinchapman/repos/backend-technical-test/test/fixtures/files/invalid.srt"))
    @valid_params = ActionController::Parameters.new(file: @file)
    @invalid_params = ActionController::Parameters.new(file: @invalid_file)
  end

  test 'creates a subtitle' do
    assert_difference('Subtitle.count') do
      SubtitlesService::Create.call(attributes: @valid_params)
    end
  end

  test 'raises errors when file invalid' do
    e = assert_raises Service::Errors::Invalid do
      SubtitlesService::Create.call(attributes: @invalid_params)
    end

    assert_equal ["Cue#2 has a non-incrementing timecode"], JSON.parse(e.message)
  end
end