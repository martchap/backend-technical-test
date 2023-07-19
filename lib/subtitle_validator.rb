require "segment_validator"
require "time_converter"

class SubtitleValidator
  class ValidationError < StandardError ; end

  attr_reader :srt, :error_messages, :expected_film_duration

  def initialize(srt, expected_film_duration: nil)
    @expected_film_duration = expected_film_duration
    @srt = srt
    @error_messages = []
    call
  end

  def call
    validate_duration
    validate_segments
  end

  def validate!
    errors.each {|e| raise(ValidationError, e) }
  end

  def errors
    @errors ||= error_messages.reverse
  end

  private

  def validate_duration
    return true unless expected_film_duration

    end_timecode = SegmentValidator.new(segments.reverse.last, nil).current_end_timestamp
    end_timecode_to_seconds = (end_timecode.to_f / 1000)
    is_too_long = end_timecode_to_seconds > expected_film_duration.to_f

    error_messages << "Subtitle duration (#{end_timecode_to_seconds}) is longer than film duration (#{expected_film_duration} seconds)" if is_too_long
  end

  def validate_segments
    segments.each_with_index do |segment, i|
      prev_segment = SegmentValidator.new(segments[i + 1], nil)
      validator = SegmentValidator.new(segment, prev_segment)
      validator.call
      validator.errors.each { |e| error_messages << e }
    end
  end

  def segments
    segments = srt.split(/\n\s*\n/).reverse
  rescue ArgumentError => e
    raise e unless e.message == "invalid byte sequence in UTF-8"

    error_messages << "Invalid file encoding. UTF-8 required."

    return []
  end
end