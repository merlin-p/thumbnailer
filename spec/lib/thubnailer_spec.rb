require 'spec_helper'

RSpec.describe Thumbnailer do
  describe 'config' do
    let(:new_path) { "/tmp/testing" }
    it 'can be configured' do
      described_class.config.cache_path = new_path
      expect(described_class.config.cache_path).to eq new_path
    end
  end

  describe 'create' do
    let!(:gem_root) { "./" || Gem::Specification.find_by_name("thumbnailer").gem_dir }
    let(:sample) { "#{gem_root}/spec/fixtures/thumbnailer/sample" }

    before do
      described_class.config.cache_path = Dir.mktmpdir
    end

    [:jpg, :png, :bmp, :tif, :mp4, :docx, :blend, :stl, :"3ds"].each do |type|
      it "creates a file with size >0 for #{type} format" do
        file = described_class.create("#{sample}.#{type}")
        expect(File.size(file)).to be > 125 # ~minimum jpeg size with header
      end
    end

    after do
      FileUtils.rm_rf(described_class.config.cache_path)
    end

  end

end
