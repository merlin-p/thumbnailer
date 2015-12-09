require 'spec_helper'

RSpec.describe Thumbnailer do
  describe 'config' do
    let(:new_path) { "/tmp/testing" }
    it 'can be configured' do
      described_class.config.cache_path = new_path
      expect( described_class.config.cache_path ).to eq new_path
    end

    it 'processes config blocks' do
      described_class.config { |c| c.mode = :pad }
      expect( described_class.config.mode ).to eq :pad
    end
  end

  describe 'create' do
    let(:sample) { "spec/fixtures/thumbnailer/sample" }

    before do
      described_class.config.cache_path = Dir.mktmpdir
    end

    it "creates thumbs for all scaling modes" do
      %i(crop scale pad).each do |mode|
        described_class.config.mode = mode
        file = described_class.create("#{sample}.jpg")
        expect( valid_image?(file) ).to be true
        expect( File.size(file) ).to be > 125 # ~minimum jpeg size with header
      end
    end

    %i(jpg png bmp tif mp4 docx).each do |type|
      it "creates a image file for #{type} format" do
        file = described_class.create("#{sample}.#{type}")
        expect( valid_image?(file) ).to be true
        expect( File.size(file) ).to be > 125 # ~minimum jpeg size with header
      end
    end

    it "handles empty files of all kinds" do
      temp = tempname
      formats.each do |ext|
        file = "#{temp}.#{ext}"
        File.write(file, nil)
        expect( described_class.create(file) ).to be nil
        File.delete(file)
      end
    end

    it "handles invalid files" do
      temp = tempname
      formats.each do |ext|
        file = "#{temp}.#{ext}"
        File.write(file, random_bin(rand(32)))
        expect( described_class.create(file) ).to be nil
        File.delete(file)
      end
    end

    it "handles missing files" do
      formats.each do |ext|
        expect( described_class.create("/DEFINITELY-NOT.HERE.#{ext}") ).to be nil
      end
    end

    it "handles invalid input" do
      expect( described_class.create(random_bin) ).to be nil
      [{}, OpenStruct.new, [], 99, 0.1, false, nil, true, Class].each do |obj|
        expect( described_class.create(obj) ).to be nil
      end
    end

    after do
      FileUtils.rm_rf( described_class.config.cache_path )
    end

  end

  describe 'which' do
    let(:name)    { "sh" }
    let(:target)  { "/bin/sh" }

    it "resolved a full path for a given name (i.e. 'sh')" do
      expect( described_class.which(name) ).to eq target
    end
  end

  describe 'reset!' do
    before(:all) do
      @temp = Dir.mktmpdir
      @files = []
      @sample = "spec/fixtures/thumbnailer/sample"
      described_class.config.cache_path = @temp

      formats.each do |ext|
        @files.push described_class.create("#{@sample}.#{ext}")
      end
    end

    it "deletes all thumbnails in the directory" do
      expect( Dir.glob("#{@temp}/*.*") ).to match_array(@files)
      described_class.reset!
      expect( Dir.glob("#{@temp}/*.*") ).to eq []
    end

    after(:all) do
      FileUtils.remove_entry @temp
    end
  end

end
