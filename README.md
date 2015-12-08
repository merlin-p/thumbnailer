# Thumbnailer

## Setup

requires imagemagick + either mplayer or ffmpeg installed and available in your path

osx:

`brew install imagemagick mplayer Caskroom/cask/blender Caskroom/cask/libreoffice`

linux:

`sudo apt-get -y install imagemagick mplayer libreoffice blender`

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


## Usage
configure (optional):
```
Thumbnailer.config do |c|
  c.thumbnail_size = 128
  c.cache_path = "#{Rails.root}/tmp/cache/assets/development/thumbnails/"
  c.render_dpi = 45
  c.mode = :scale
  c.background_color = "black"
end
```

`Thumbnailer.create("my.file")` and you'll get the full filename (including path) to your thumbnail
