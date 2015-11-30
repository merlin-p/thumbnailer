module Thumbnailer
  module Office
    extend self

    def supported_formats
      %i(doc docx xls xlsx ppt pptx)
    end

    def render_dpi
      Thumbnailer.config.render_dpi
    end

    def process(file, output)
      temp = Dir.mktmpdir
      if (soffice = Thumbnailer.which('soffice'))
        `#{soffice} --headless --invisible --nocrashreport --nodefault --nofirststartwizard --nologo --norestore --convert-to pdf --outdir "#{temp}" "#{file}"`
        if $?.exitstatus==0 && (file = Dir["#{temp}/*.pdf"].first)
          PDF.process(file, output)
        end
      end
    end
  end
end
