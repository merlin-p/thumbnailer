$LOAD_PATH.unshift "./thumbnailer"

require 'thumbnailer/version'
require 'thumbnailer/three'
require 'thumbnailer/pdf'
require 'thumbnailer/resize'
require 'thumbnailer/office'
require 'thumbnailer/video'

require 'zlib'
require 'ostruct'
require 'fileutils'
require 'tmpdir'
require 'tempfile'

module Thumbnailer

  @which_cache = {}

  extend self

  def default_options
    OpenStruct.new(
        thumbnail_size: 64,
        render_dpi: 90,
        video_skip_to: 1,
        cache_path: "/tmp",
        mode: :pad,
        background_color: :white
    )
  end

  def config(&blk)
    @config ||= default_options
    blk.call(@config) if block_given?
    @config
  end

  def create(file)
    return nil unless (file.is_a?(String) && File.exists?(file) && File.size(file)>1000)
    using_cache(file) do |cache|
      file_type = file_ext(file)
      if Resize.supported_formats.include?(file_type)
        FileUtils.cp(file, cache)
      elsif supported_formats.include?(file_type)
        module_by_filetype(file_type).send(:process, file, cache)
      else
        return nil
      end
      Resize.process(cache)
    end
  end

  def which(name)
    @which_cache[name] ||= (
      find_executable(name.to_s) || Dir.glob("{#{ENV['HOME']},}/Applications/*.app/Contents/MacOS/#{name}").first
    )
  end

  def reset!
    Dir.glob( File.join( config.cache_path, '*.jpg' ) )
      .select { |file| File.basename(file) =~ /[a-f\d]{7,8}\.jpg/ }
      .each   { |file| File.delete(file) }
  end

  def supported_formats
    thumbnailer_modules
      .flat_map(&:supported_formats)
  end

  private

    def using_cache(file)
      cfile = cache_file(file)
      return cfile if File.exists?(cfile)
      yield(cfile) if block_given?
    end

    def find_executable(name)
      if file_path = find_path(name)
        File.join(file_path, name)
      end
    end

    def find_path(name)
      ENV['PATH']
        .split(':')
        .select { |path| File.exists?(File.join(path, name)) }
        .first
    end

    def module_by_filetype(type)
      thumbnailer_modules
        .select { |mod| mod.respond_to?(:supported_formats) && mod.supported_formats.include?(type.downcase.to_sym) }
        .first
    end

    def thumbnailer_modules
      constants
        .select { |com| const_get(com).is_a? Module }
        .map    { |mod| const_get(mod) }
    end

    def cache_path
      cache = config.cache_path
      FileUtils.mkdir_p(cache) unless Dir.exists?(cache)
      cache
    end

    def checksum(input)
      Zlib.crc32(input, 0).to_s(16)
    end

    def cache_file(file)
      "#{cache_path}/#{checksum(File.read(file))}.jpg"
    end

    def file_ext(file)
      File.extname(file).sub(/^\./, '').to_sym
    end
end
