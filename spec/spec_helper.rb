require 'fileutils'
require 'tempfile'
require_relative '../lib/thumbnailer.rb'

module SpecHelpers
  def valid_image?(file)
    return nil unless File.exists?(file)
    # if we do not have imagemagick here, tests would have failed already :)
    dimensions = `identify -ping -format '%w %h' "#{file}"`.split.map(&:to_i)
    dimensions.map(&8.method(:<=)).all?
  end

  def random_bin(length=8)
    (0..length).inject('') { |p,c| p + rand(255).chr }
  end

  def tempname
    Dir::Tmpname.make_tmpname('/tmp/', nil)
  end

  def formats
    %i(jpg png bmp tif mp4 docx eps ai)
  end
end

RSpec.configure do |c|
  c.include SpecHelpers
end
