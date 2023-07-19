class SegmentValidator
  class HtmlTagError < StandardError ; end
  attr_reader :segment, :errors, :prev_segment

  PATTERN = /^(\d+|\D+)\n(\s?\d{2,3}\s?:\s?\d{2,3}\s?:\s?\d{2,3},\d{2,3}) --> (\s?\d{2}\s?:\s?\d{2}\s?:\s?\d{2}\s?,\d{2,3})(?:\n([\s\S]*?(?:\n\n|\z)))*/
  HTML_PATTERN = /(<[^>]+>)?([^<]*)?(<\/[^>]+>)?/
  FPS = 24

  def initialize(segment, prev_segment)
    @segment = segment
    @prev_segment = prev_segment
    @errors = [] 
  end

  def call
    validate_timecode_format
    validate_line_number
    validate_cues
    validate_html_tags
    validate_start_timecodes
    validate_segment_duration
  end

  def line_number
    @line_number ||= matches[0]
  end

  def cues
    @cues = matches[3]
  end

  def end_timecode
    @end_timecode ||= matches[2]
  end

  def current_start_timestamp
    @current_start_timestamp ||= TimeConverter.hmsms_to_ms(start_timecode)
  end

  def current_end_timestamp
    @current_end_timestamp ||= TimeConverter.hmsms_to_ms(end_timecode)
  end

  private

  def milliseconds_per_frame
    1000 / FPS
  end

  def validate_segment_duration
    return unless (current_end_timestamp - current_start_timestamp).positive?
    return unless (current_end_timestamp - current_start_timestamp) <= milliseconds_per_frame

    errors << "Cue##{line_number} has a too short duration"
  end

  def validate_timecode_format
    [start_timecode, end_timecode].each do |timecode|
      next if timecode.match(/\d{2}:\d{2}:\d{2},\d{3}/)

      errors << "Timecode #{timecode} is badly formed"
    end
  end

  def start_timecode
    @start_timecode ||= matches[1]
  end

  def previous_end_timestamp
    TimeConverter.hmsms_to_ms(prev_segment.end_timecode)
  end

  def matches
    @matches ||= segment.scan(PATTERN).flatten
  end

  def validate_start_timecodes
    return true unless prev_segment.segment

    errors << "Cue##{line_number} has a non-incrementing timecode" && return if invalid_timestamp?
  end

  def invalid_timestamp?
    current_start_timestamp < previous_end_timestamp
  end

  def validate_cues
    errors << "Cue##{line_number} is empty" && return unless cues.presence
    errors << "Cue##{line_number} has 3 or more lines" && return unless cues.split("\n").count <= 2
  end

  def validate_html_tags
    return unless cues

    cues.scan(HTML_PATTERN).select {|c| c.first.present? || c.last.present?}.each do |tag|
      Nokogiri::XML.parse(tag.join) { |config| config.strict }

      raise HtmlTagError if Nokogiri::HTML::DocumentFragment.parse(tag.join).errors.any?

      validate_empty_html_tags
    rescue Nokogiri::XML::SyntaxError => e
      errors << "Cue##{line_number} contains badly formed HTML"
    rescue HtmlTagError => e
      errors << "Cue##{line_number} contains invalid HTML tags"
    end
  end

  def validate_empty_html_tags
    cues.scan(HTML_PATTERN).select {|c| (c.first.present? || c.last.present?) && (c[1].empty? || !c[1].match?(/\w/))}.each do |tag|
      errors << "Cue##{line_number} contains empty HTML tags"
    end
  end

  def validate_line_number
    errors << "Failed to match group of lines 2 starting: #{line_number}" && return if line_number.to_i.zero?
  end
end