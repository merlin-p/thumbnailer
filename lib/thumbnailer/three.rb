module Thumbnailer::Three
  extend self

  def supported_formats
    %i(blend 3ds obj stl dae)
  end

  def render_dpi
    Thumbnailer.config.render_dpi
  end

  def process(file, output)
    if (blender = Thumbnailer.which('blender'))
      temp = Dir.mktmpdir
      IO.write("#{temp}/render.py", render_script(output))
      `"#{blender}" "#{file}" -P "#{temp}/render.py"`
      FileUtils.rm_rf temp
      $?.exitstatus==0 && File.exists?(output)
    end
  end

  private

    def render_script(output)
      %{
import bpy
import os

# path to the folder
file_path = bpy.data.filepath
file_name = bpy.path.display_name_from_filepath(file_path)
file_ext = '.blend'
file_dir = file_path.replace(file_name+file_ext, '')

#set render settings
bpy.data.scenes[0].render.resolution_x = 128
bpy.data.scenes[0].render.resolution_y = 128
bpy.data.scenes[0].render.resolution_percentage = 100
#render
bpy.ops.render.opengl(view_context = False)
#save image
img_name = "#{output}"
base_name = "#{File.basename(output)}"
bpy.data.images['Render Result'].save_render(img_name)
bpy.ops.image.open(filepath = img_name)
bpy.data.images[base_name].pack()
#close blender
bpy.ops.wm.quit_blender()
      }
    end
end
