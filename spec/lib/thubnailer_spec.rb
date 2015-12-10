require 'spec_helper'

RSpec.describe Thumbnailer do
  describe '.config' do
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

  describe '.create' do
    let(:sample)  { "spec/fixtures/thumbnailer/sample" }
    let(:default) { "#{sample}.jpg" }
    let(:size)    { 8 + Random.rand(256) }
    let(:output)  { "#{tempname}.jpg" }

    before do
      described_class.config.cache_path = Dir.mktmpdir
    end

    it "respects output file" do
      described_class.create(default, output)
      expect( valid_image?(output) ).to be true
      File.delete(output)
    end

    it "scales images according to thumbnail_size" do
      described_class.config.thumbnail_size = size
      file = described_class.create(default)
      expect( dimensions(file) ).to include(size)
    end

    it "creates thumbs for all scaling modes" do
      %i(crop scale pad).each do |mode|
        described_class.config.mode = mode
        file = described_class.create(default)
        expect( valid_image?(file) ).to be true
      end
    end

    it "creates thumbnails for various formats" do
      %i(jpg mp4 docx eps ai).each do |ext|
        file = described_class.create("#{sample}.#{ext}")
        expect( valid_image?(file) ).to be true
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

    after { FileUtils.rm_rf( described_class.config.cache_path ) }

  end

  describe '.which' do
    let(:name)    { "sh" }
    let(:target)  { "/bin/sh" }

    it "resolved a full path for a given name (i.e. 'sh')" do
      expect( described_class.which(name) ).to eq target
    end
  end

  describe '.reset!' do
    before(:all) do
      @temp = Dir.mktmpdir
      @files = []
      @sample = "spec/fixtures/thumbnailer/sample"
      described_class.config.cache_path = @temp

      formats.each do |ext|
        @files.push described_class.create("#{@sample}.#{ext}")
      end

      @injected_file = File.join(@temp, 'some other file.sh')

      File.write(@injected_file, "CONTENT")
    end

    it "deletes all thumbnails in the directory and no other files" do
      expect( Dir.glob("#{@temp}/*.*") ).to match_array(@files.compact + [@injected_file])
      described_class.reset!
      expect( Dir.glob("#{@temp}/*.*") ).to eq [@injected_file]
    end

    it "leaves other files unharmed" do
      expect( File.read(@injected_file) ).to eq "CONTENT"
    end

    after(:all) do
      FileUtils.remove_entry @temp
    end
  end

end
