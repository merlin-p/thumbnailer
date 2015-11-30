module Thumbnailer
  module PDF
    extend self

    def supported_formats
      %i(pdf)
    end

    def render_dpi
      Thumbnailer.config.render_dpi
    end

    def process(file, output)
      if Thumbnailer.which 'gs'
        `gs -dNOPAUSE -dBATCH -r#{render_dpi} -sDEVICE=jpeg -sOutputFile="#{output}" -dFirstPage=1 -dLastPage=1 "#{file}"`
      elsif Thumbnailer.which 'convert'
        `convert -density #{render_dpi} -trim "#{file}[0]" -quality 100 "#{output}"`
      end
      $?.exitstatus==0
    end
  end
end
