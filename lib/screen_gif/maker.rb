require 'streamio-ffmpeg'
require 'RMagick'
require 'pathname'
require 'pry'
module ScreenGif
  class Maker
    def initialize(movie_path, opts = {})
      @movie_path = movie_path
      @movie = open_movie_path(@movie_path)
      @pwd = init_working_directory(opts['pwd'], @movie_path)
    end


    def make(opts={})
      i_start = (opts['start'].to_f * 100).floor / 100.0
      i_end = ((opts['end'] || movie_duration).to_f * 100).floor / 100.0
      interval_ms = (opts['interval'] || 250).to_i

      gif_basename = opts[:basename] || File.basename(@movie_path) +
            "--#{seconds_to_timestamp_fname i_start}--#{seconds_to_timestamp_fname i_end}.gif"
      screenshots = make_screenshots(i_start, i_end, interval_ms, opts)
      gname = make_gif(gif_basename, screenshots,  opts)

      puts "Successfully created #{gname}"
    end

    # returns gif file name upon success
    def make_gif(gif_basename, screenshot_filenames, opts={})
      gifs_path.mkpath
      gif_full_name = gifs_path.join(gif_basename)
      # tk quick hack to use 10th frame
      screens = screenshot_filenames.each_slice(10).map(&:first)
      gif_img = Magick::ImageList.new(*screens)

      gif_img.write(gif_full_name)
      return gif_full_name
    end

    # creates screenshots
    # returns a list of valid screenshots
    def make_screenshots(start_sec, end_sec, interval_ms, opts={})
      # make the directory
      screenshots_path.mkpath
      # figure out zeropadding for file naming purposes
      zeropads = Math.log(movie_duration, 10).round + 1
      screenshot_filenames = []

      ((start_sec * 1000)..(end_sec * 1000)).step(interval_ms) do |s|
        d = (s / 1000.0).round(2)
        puts "#{s} -> #{d}"
        ## HACK: don't know why this can't encode final moment, so skip for now
        next if d >= end_sec
        ###
        fname = screenshots_path.join(seconds_to_timestamp_fname(d) + '.png')
        if !fname.exist?
          puts fname
          @movie.screenshot(fname, seek_time: d)
        end
        screenshot_filenames << fname
      end

      return screenshot_filenames
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

    # expects @movie to be a FFMPeg::Movie
    def movie_duration
      @movie.duration
    end

    def open_movie_path(mpath)
      FFMPEG::Movie.new mpath
    end

    # num is expected to be a float/integer of seconds
    def seconds_to_timestamp_fname(num)
      s = (num % 60)
      msec = (s.to_s[/(?<=\.)\d{1,3}/]).ljust(3, '0')
      sec = '%02i' % s.round
      minutes = '%02i' % (num / 60 )
      hours = '%02i' % (num / 3600)

      return "#{hours}_#{minutes}_#{sec}.#{msec}"
    end
  end
end




    # def calc_frames

    # end

    # def make_annotations

    # end

    # def make_sequence

    # end

  #  `convert -delay 100 -size 500x300 #{files.join(' ')} test2.gif`
