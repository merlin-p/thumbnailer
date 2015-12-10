module Thumbnailer::Resize
  extend self

  def supported_formats
    %i(jpg png tif tiff bmp pcx dng dot ico tga gif eps ps svg pnm ai psd)
  end

  def process(file)
    if Thumbnailer.which('convert')
      return unless dimensions(file)
      case mode
      when :crop
        `convert -quality #{quality} "#{file}" -resize #{square}^ -gravity #{gravity} -extent #{square} "#{file}"`
      when :scale
        `convert -quality #{quality} -define #{format}:size=#{dimensions(file).join('x')} "#{file}" -thumbnail #{square} "#{file}"`
      when :pad
        `convert -quality #{quality} -define #{format}:size=#{dimensions(file).join('x')} "#{file}" -thumbnail #{square} -background #{background_color} -gravity #{gravity} -extent #{square} "#{file}"`
      else
        raise "invalid mode given: '#{mode}'"
      end
      $?.exitstatus==0 ? file : nil
    else
      raise "ImageMagick is required to generate thumbnails, please install using your package manager."
    end
  end

  private

  def dimensions(file)
    dim = `identify -ping -format "%w %h" "#{file}"`
    if $?.exitstatus!=0 || dim !~ /\d+ \d+/
      return nil
    else
      dim.split.map(&:to_i)
    end
  end

  def gravity
    "center"
  end

  def format
    "jpeg"
  end

  def quality
    Thumbnailer.config.quality.to_i
  end

  def mode
    Thumbnailer.config.mode.to_sym
  end

  def background_color
    Thumbnailer.config.background_color
  end

  def size
    Thumbnailer.config.thumbnail_size || Thumbnailer.config.size
  end

  def square
    "#{size}x#{size}"
  end
end
