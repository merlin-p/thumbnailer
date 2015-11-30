module Thumbnailer::Video
  extend self

  def supported_formats
    %i(mp4 mp2 m2v mkv avi mov qt m4v rm rmvb asf flv ogm dv)
  end

  def skip_to
    Thumbnailer.config.video_skip_to
  end

  def process(file, output)
    temp = Dir.mktmpdir
    if Thumbnailer.which 'mplayer'
      `mplayer "#{file}" -ss #{skip_to} -nosound -vo png:outdir=#{temp} -frames 1 2>/dev/null`
      return nil if $?.exitstatus!=0
      File.rename Dir["#{temp}/*.*"].first, output
    elsif Thumbnailer.which 'ffmpeg'
      `ffmpeg -i "#{file}" -ss 00:00:#{skip_to.to_s.rjust(2, '0')}.000 -vframes 1 #{output}`
    elsif Thumbnailer.which 'convert'
      `convert "#{file}[30]" "#{output}"`
    end
    $?.exitstatus==0
  end
end
