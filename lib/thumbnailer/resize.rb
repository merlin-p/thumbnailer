module Thumbnailer::Resize
  extend self

  def supported_formats
    %i(jpg png tif tiff bmp pcx dng dot ico tga gif eps ps svg pnm)
  end

  def size
    Thumbnailer.config.thumbnail_size
  end

  def square
    "#{size}x#{size}"
  end

  def process(file, output)
    return nil if !Thumbnailer.which('convert')
    `convert "#{file}" -resize #{square}^ -gravity center -extent #{square} "#{output}"`
    $?.exitstatus==0 ? output : nil
  end
end
