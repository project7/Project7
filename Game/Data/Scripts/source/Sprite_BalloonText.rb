#encoding:utf-8

class Sprite_BalloonText < Window
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(text)
    skin = Cache.system("MUISkin").dup
    skin.font.size = 20
    skin.font.outline = false
    size = skin.text_size(text)
    super 0, 0, size.width + standard_padding * 2, size.height + standard_padding * 2
    self.windowskin = skin
    update_padding
    create_contents
    self.contents.font = skin.font
    self.contents.draw_text(0, 0, width, contents_height, text)
    self.opacity = 255
    self.back_opacity = 255
    @balloon_sprite = ::Sprite.new(viewport)
    @balloon_sprite.bitmap = Cache.system("MUIS")
    update
  end
  def dispose
    contents.dispose unless disposed?
    @balloon_sprite.dispose
    super
  end
  def line_height
    return 24
  end
  def standard_padding
    return 6
  end
  def update_padding
    self.padding = standard_padding
  end
  def contents_width
    width - standard_padding * 2
  end
  def contents_height
    height - standard_padding * 2
  end
  def fitting_height(line_number)
    line_number * line_height + standard_padding * 2
  end
  def create_contents
    contents.dispose
    if contents_width > 0 && contents_height > 0
      self.contents = Bitmap.new(contents_width, contents_height)
    else
      self.contents = Bitmap.new(1, 1)
    end
  end
  def update
    super
    @balloon_sprite.update
    @balloon_sprite.x = self.x + 13
    @balloon_sprite.y = self.y + self.height
    @balloon_sprite.opacity = self.opacity
    self.contents_opacity = self.opacity
    self.back_opacity = self.opacity
  end
  def text_color(n)
    windowskin.get_pixel(64 + (n % 8) * 8, 96 + (n / 8) * 8)
  end
  def draw_text(*args)
    contents.draw_text(*args)
  end
  def text_size(str)
    contents.text_size(str)
  end
end
