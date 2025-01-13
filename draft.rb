@bpm = 60

def beat_duration(ratio)
  ratio * 60.0 / @bpm
end

def build_play_command(frequency, duration)
  fade_duration = 0.01
  "ffmpeg -f lavfi -i sine=frequency=#{frequency}:duration=#{duration} -af 'afade=t=in:st=0:d=#{fade_duration}, afade=t=out:st=#{duration - fade_duration}:d=#{fade_duration}' -f alsa default"
end

def note_to_frequency(note)
  frequencies = {
    "C4" => 261.63,
    "C#4" => 277.18,
    "D4" => 293.66,
    "D#4" => 311.13,
    "E4" => 329.63,
    "F4" => 349.23,
    "F#4" => 369.99,
    "G4" => 392.00,
    "G#4" => 415.30,
    "A4" => 440.00,
    "A#4" => 466.16,
    "B4" => 493.88,
  }
  frequencies[note] || 440.00  # Default to A4 if note is not found
end

def play(note, ratio = 0.5)
  duration = beat_duration(ratio)

  return sleep(duration) if note == "pause"

  frequency = note_to_frequency(note)

  system(build_play_command(frequency, duration))
end

def blank(duration)
  system(build_play_command(0, duration))
end

blank(0.5)

notes_and_durations = [
  { note: "C4", duration: 0.5 },
  { note: "E4", duration: 0.25 },
  { note: "G4", duration: 0.25 },
  { note: "A4", duration: 0.25 },
  { note: "E4", duration: 0.25 },
  { note: "G4", duration: 0.25 },
  { note: "A4", duration: 0.25 },
  { note: "E4", duration: 0.25 },
  { note: "G4", duration: 0.25 },
  { note: "A4", duration: 0.25 },
  { note: "pause", duration: 0.125 },
  { note: "F4", duration: 0.125 },
]

notes_and_durations.each do |item|
  play(item[:note], item[:duration])
end
