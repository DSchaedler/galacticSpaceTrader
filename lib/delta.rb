# provide profiling fuctions
module Delta
  def mark
    now ||= Time.now
    $delta ||= now
    if $gtk.args.state.tick_count % 10 == 0
      now = Time.now
    else
      now = $delta
    end
    $gtk.args.outputs.primitives << { x: 640, y: 700, text: "Delta: #{((now - $delta) * 1000.0).round(2)}ms", alignment_enum: 1, r: 255, g: 255, b: 255 }.label! if $delta
    $delta = now if now
  end
end

Delta.extend Delta
