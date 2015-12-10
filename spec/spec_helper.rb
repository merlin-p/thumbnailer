require 'fileutils'
require 'tempfile'
require_relative '../lib/thumbnailer.rb'

module SpecHelpers
  def valid_image?(file)
    return nil unless File.exists?(file)
    dimensions(file).inject(:+) > 8
  end

  def dimensions(file)
    return nil unless File.exists?(file)
    `identify -ping -format '%w %h' "#{file}"`.split.map(&:to_i)
  end

  def random_bin(length=8)
    (0..length).inject('') { |p,c| p + rand(255).chr }
  end

  def tempname
    Dir::Tmpname.make_tmpname('/tmp/', nil)
  end

  def formats
    Thumbnailer.send(:thumbnailer_modules)
      .select { |m| m != Thumbnailer::Three }
      .map    { |m| m.supported_formats.first }
  end
end

RSpec.configure do |c|
  c.include SpecHelpers
end
