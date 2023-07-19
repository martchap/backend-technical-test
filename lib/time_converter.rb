class TimeConverter
  def self.hmsms_to_ms(timestamp)
    return nil unless timestamp

    hms, miliseconds = timestamp.split(",")
    hours, minutes, seconds = hms.split(":").map(&:to_i)
    (hours * 3600 + minutes * 60 + seconds) * 1000 + miliseconds.to_i
  end
end