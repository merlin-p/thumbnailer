# Thumbnailer
[![Build Status](https://travis-ci.org/merlin-p/thumbnailer.svg)](https://travis-ci.org/merlin-p/thumbnailer)

## Setup

requires imagemagick + either mplayer or ffmpeg installed and available in your path

**osx**: `brew install imagemagick mplayer Caskroom/cask/blender Caskroom/cask/libreoffice`

**linux**: `sudo apt-get install imagemagick mplayer blender libreoffice`

## Usage
add to your **Gemfile**:
`gem 'thumbnailer', git: 'https://github.com/merlin-p/thumbnailer.git'`

configure (optional):
```
# direct manipulation
Thumbnailer.config.mode = :pad

# set options only for a given block
Thumbnailer.with_options(quality: 100, size: 512) { |t| t.create(input, output) }

# configure using a block
Thumbnailer.config do |c|
  c.size = 128
  c.cache_path = "#{Rails.root}/tmp/cache/assets/#{Rails.env}/thumbnails/"
  c.render_dpi = 45
  c.mode = :pad
  c.background_color = :blue
end
```

`Thumbnailer.create("my.file")` and you'll get the full filename (including path) to your thumbnail. in case there are problems (e.g. with processing, input or output) it returns nil. when using a supported format without the required application installed it will raise an exception.

an output filename is optional (should always end in .jpg ATM):

`Thumbnailer.create("my.file", "my.output")`


## Configuration

- `thumbnail_size` default: 64

maximum size for both sides of the image (depending on your mode it will either crop or resize to match this limitation), in pixel

- `render_dpi` default: 90

the rasterization resolution for Vector Graphics, in DPI

- `video_skip_to` default: 1

for video thumbnails: skip the video to this point before taking a thumbnail, in seconds

- `cache_path` default: "/tmp"

where to save thumbnails,

- `mode` default: :pad

can be either :scale (scale adjusting the larger side to fit thumbnail_size), :crop (scale then crop to fit a square) or :pad (pad the scaled image to fit a square, use background_color to adjust the filling)

- `background_color` default white

standard ImageMagick colors, check out "List of Color Names" over here: http://www.imagemagick.org/script/color.php

## Supported Formats

currently there is support for Office formats including PDF (using libre/openoffice), Images (using ImageMagick), Videos (using mplayer or ffmpeg) and 3D formats (using blender). 3D rendering will not work on a headless setup and has issues with some formats, so its use is discouraged at the moment.

Images
- jpg, png, tif, tiff, bmp, pcx, dng, dot, ico, tga, gif, eps, ps, svg, pnm, ai, psd

Office
- doc, docx, xls, xlsx, ppt, pptx, pdf

Videos
- mp4, m4v, mp2, m2v, mkv, avi, mov, qt, rm, rmvb, asf, flv, ogm, dv, mpg, mpeg, wmv

3D
- blend, 3ds, obj, stl, dae
