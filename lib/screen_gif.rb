require_relative './screen_gif/maker'
module ScreenGif
  class Sequence
    attr_reader :start_time, :end_time, :fps

    def duration
      end_time - start_time
    end

    def frames

    end

    def frame_timestamps

    end
  end

  class DelayedSequence < Sequence
    attr_reader :delay
    def duration
      delay
    end
  end
end

