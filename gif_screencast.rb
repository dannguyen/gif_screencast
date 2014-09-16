require 'streamio-ffmpeg'
require 'mini_magick'
require 'pathname'


module ScreenGif
  class Maker

    def initialize(movie_path, opts = {})
      @movie_path = movie_path
      @movie = open_movie_path(@movie_path)
      @pwd = init_working_directory(opts['pwd'], @movie_path)
    end

    # def calc_frames

    # end

    # def make_annotations

    # end

    # def make_sequence

    # end

  #  `convert -delay 100 -size 500x300 #{files.join(' ')} test2.gif`

    def make_gif(opts={})
      i_start = opts[:start].to_f.round(2)
      i_end = opts[:end].to_f.round(2)
      frame_skip = 10 # TK -- remove later

      basename = opts[:basename] || File.basename(@movie_path) +
            "#{seconds_to_timestamp_fname i_start}--#{seconds_to_timestamp_fname i_end}.gif"



    end

    # creates screenshots
    def make_screenshots(opts = {})
      # make the directory
      screenshots_path.mkpath
      # calculate the time between each screenshot
      xs = opts[:interval].to_i
      xs = 0.25 unless xs > 0
      step_size  = xs * 100  # e.g. 25
      # figure out zeropadding for file naming purposes
      zeropads = Math.log( @movie.duration, 10).round + 1

      (0..(@movie.duration * 100)).step(step_size) do |s|
        d = (s / 100.0).round(2)
        fname = screenshots_path.join(seconds_to_timestamp_fname(d) + '.png')
        if !fname.exist?
          @movie.screenshot(fname, seek_time: d)
        end
      end

  #    @movie.screenshot(screenshots_path.join '1.png')
    end



    module Paths
      def screenshots_path
        @pwd.join 'screenshots'
      end

      def gifs_path
        @pwd.join 'gifs'
      end
    end
    include Paths

    private
    def init_working_directory(pdir, mpath)
      if pdir && !pdir.empty?
        p = Pathname.new pdir
      else
        p = Pathname.new(File.join( File.expand_path('..', __FILE__), File.basename(mpath) + '-screengif'))
      end
      p.mkpath

      return p
    end

    def open_movie_path(mpath)
      FFMPEG::Movie.new mpath
    end

    # num is expected to be a float/integer of seconds
    def seconds_to_timestamp_fname(num)
      s = (num % 60)
      msec = '%03i' % (s.to_s[/(?<=\.)\d{3}/]).to_i.round
      sec = '%02i' % s.round
      minutes = '%02i' % (num % 3600 )
      hours = '%02i' % (num / 3600)

      return "#{hours}_#{minutes}_#{sec}.#{msec}"
    end
  end


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


=begin



name:
  default:
    fps: "10%" # 10% or 5
    delay: 0.200
annotations:
  - at: "1:23"
    delay: 2
    text: "Hello world"
  - at: "2:23.50"
    text: "Another thing"
    tween:
      start: "2:23"
      end: "2:25"

tweens:
  - start: 3
    end: 5
    time_compression:

=end
