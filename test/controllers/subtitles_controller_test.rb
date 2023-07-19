require "test_helper"

class SubtitlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subtitle = subtitles(:one)
    @file = Rack::Test::UploadedFile.new(File.open("/Users/martinchapman/repos/backend-technical-test/test/fixtures/files/pulp-fiction.srt"))
    @invalid_file = Rack::Test::UploadedFile.new(File.open("/Users/martinchapman/repos/backend-technical-test/test/fixtures/files/invalid.srt"))
  end

  test "should get index" do
    get subtitles_url
    assert_response :success
    assert_equal 2, assigns(:subtitles).count
  end

  test "should get new" do
    get new_subtitle_url
    assert_response :success
  end

  test "should create subtitle" do
    assert_difference('Subtitle.count') do
      post subtitles_url, params: { subtitle: { file: @file } }
    end

    assert_redirected_to subtitle_url(Subtitle.last)
  end

  test "should fail and redirect with invalid srt" do
    assert_no_changes('Subtitle.count') do
      post subtitles_url, params: { subtitle: { file: @invalid_file } }
    end

    assert_response :unprocessable_entity
  end

  test "should return an array of errors" do
    assert_no_changes('Subtitle.count') do
      post subtitles_url, params: { subtitle: { file: @invalid_file } }
    end

    assert_equal ["Cue#2 has a non-incrementing timecode"], assigns(:errors)
  end

  test "should show subtitle" do
    get subtitle_url(@subtitle)
    assert_response :success
  end

  test "should get edit" do
    get edit_subtitle_url(@subtitle)
    assert_response :success
  end

  test "should update subtitle" do
    patch subtitle_url(@subtitle), params: { subtitle: { file: @file } }
    assert_redirected_to subtitle_url(@subtitle)
  end

  test "fails with invalid file" do
    patch subtitle_url(@subtitle), params: { subtitle: { file: @invalid_file } }
    assert_response :unprocessable_entity
    assert_equal ["Cue#2 has a non-incrementing timecode"], assigns(:errors)
  end

  test "should destroy subtitle" do
    assert_difference('Subtitle.count', -1) do
      delete subtitle_url(@subtitle)
    end

    assert_redirected_to subtitles_url
  end
end
