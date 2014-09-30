# convenience script to run from command line for now

require_relative './lib/screen_gif'

video_fname = ARGV.shift
working_dir = ARGV.shift

puts "-- making gif from #{video_fname} and storing into #{working_dir}"
puts "-- running Maker.make_gif..."

maker = ScreenGif::Maker.new video_fname, {'pwd' => working_dir}
maker.make
