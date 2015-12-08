module Thumbnailer::Video
  extend self

  def supported_formats
    %i(mp4 mp2 m2v mkv avi mov qt m4v rm rmvb asf flv ogm dv)
  end

  def skip_to
    Thumbnailer.config.video_skip_to
  end

  def process(file, output)
    file = File.expand_path(file, Dir.pwd)
    Dir.mktmpdir do |temp|
      Dir.chdir(temp) do
        if Thumbnailer.which 'mplayer'
          `mplayer "#{file}" -ss #{skip_to} -nosound -vo png -frames 1 2>/dev/null`
          return nil if $?.exitstatus!=0
          File.rename Dir["*.png"].first, output
        elsif Thumbnailer.which 'ffmpeg'
          `ffmpeg -i "#{file}" -ss 00:00:#{skip_to.to_s.rjust(2, '0')}.000 -vframes 1 #{output}`
        elsif Thumbnailer.which 'convert'
          `convert "#{file}[#{skip_to*25}]" "#{output}"`
        else
          raise "mplayer, ffmpeg or ImageMagick(using ffmpeg) is required to generate thumbnails for Video Files: #{supported_formats.join(', ')}"
        end
        $?.exitstatus==0
      end
    end
  end
end
