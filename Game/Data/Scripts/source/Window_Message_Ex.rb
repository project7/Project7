=begin
class Window_Message_Ex < Window_Message
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    super
    self.opacity = 0
    create_figure
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_figure
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    update_figure
  end
  #--------------------------------------------------------------------------
  # ● 生成背景位图
  #--------------------------------------------------------------------------
  def create_back_bitmap
    @back_bitmap = Cache.system("MUIB")
  end
  #--------------------------------------------------------------------------
  # ● 创建立绘
  #--------------------------------------------------------------------------
  def create_figure
    @figure = Sprite.new
    @figure.bitmap = Cache.system("未命名-16")
    @figure.z = z + 3
  end
  #--------------------------------------------------------------------------
  # ● 更新立绘
  #--------------------------------------------------------------------------
  def update_figure
    @figure.visible = (@background == 1)
    @figure.y = y
    @figure.opacity = openness
    @figure.update
  end
  #--------------------------------------------------------------------------
  # ● 弃置立绘
  #--------------------------------------------------------------------------
  def dispose_figure
    @figure.bitmap.dispose if @figure.bitmap != nil
    @figure.dispose
  end
  #--------------------------------------------------------------------------
  # ● 进行控制符的事前变换
  #    在实际绘制前、将控制符替换为实际的内容。
  #    为了减少歧异，文字「\」会被首先替换为转义符（\e）。
  #--------------------------------------------------------------------------
  def convert_escape_characters(text)
    result = text.to_s.clone
    result = "\n" + result
    result.gsub!(/\n(.*)：/){ "\n\\X[#{$1}]"}
    result.slice!(0,1)
    result.gsub!(/\\/)            { "\e" }
    result.gsub!(/\e\e/)          { "\\" }
    result.gsub!(/\eV\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/\eV\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/\eN\[(\d+)\]/i) { actor_name($1.to_i) }
    result.gsub!(/\eP\[(\d+)\]/i) { party_member_name($1.to_i) }
    result.gsub!(/\eG/i)          { Vocab::currency_unit }
    result
  end
  #--------------------------------------------------------------------------
  # ● 获取控制符的参数（这个方法会破坏原始数据）
  #--------------------------------------------------------------------------
  def obtain_escape_string(text)
    text.slice!(/^\[([^\]]*?)\]/)
    $1.to_s
  end
  #--------------------------------------------------------------------------
  # ● 处理普通文字
  #--------------------------------------------------------------------------
  def process_normal_character(c, text, pos)
    text_width = text_size(c).width
    if real_width - pos[:x] > text_width
      draw_text(pos[:x], pos[:y], text_width * 2, pos[:height], c)
      pos[:x] += text_width
    else 
      process_new_line(text,pos)
      process_normal_character(c,text,pos)
    end
  end
  #--------------------------------------------------------------------------
  # ● 控制符的处理
  #     code : 控制符的实际形式（比如“\C[1]”是“C”）
  #     text : 绘制处理中的字符串缓存（字符串可能会被修改）
  #     pos  : 绘制位置 {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_escape_character(code, text, pos)
    case code.upcase
    when 'C'
      change_color(text_color(obtain_escape_param(text)))
    when 'I'
      process_draw_icon(obtain_escape_param(text), pos)
    when '{'
      make_font_bigger
    when '}'
      make_font_smaller
    when 'X'
      make_speaker(obtain_escape_string(text), pos)
    when 'A'
      char_id = obtain_escape_param(text)
      change_action(get_action_path(char_str))
    when 'L'
      char_str = obtain_escape_string(text)
      change_emotion(get_emotion_path(char_str))
    when 'MC'
      case obtain_escape_string(text)
      when "左"
        @figure.x = 0
      when "右"
        @figure.x = Graphics.width - @figure.bitmap.width
      end
    when 'MB'
      transform_style(obtain_escape_param(text))
    when 'MN'
      transform_style(2)
      char_id = obtain_escape_param(text)
      if char_id > 0
        self.x = ($game_map.events[char_id].x + $game_map.display_x)*8
        self.y = ($game_map.events[char_id].y + $game_map.display_y)*8 + 16
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 变换对话框模式
  #--------------------------------------------------------------------------
  def transform_style(style)
    case style
    when 0
      @back_bitmap = Cache.system("MUIB")
    when 1
      @back_bitmap = Cache.system("MUIM")
    when 2
      @back_bitmap = Cache.system("MUIS")
    end
    @style = style
  end
  #--------------------------------------------------------------------------
  # ● 变换动作
  #--------------------------------------------------------------------------
  def change_action(path)
    bmp = Bitmap.new(path)
    @figure.bitmap = bmp
  end
  #--------------------------------------------------------------------------
  # ● 转换动作汉字到实际图像路径
  #--------------------------------------------------------------------------
  def get_action_path(str)
    #TODO
    path = ""
    return path
  end
  #--------------------------------------------------------------------------
  # ● 变换表情
  #--------------------------------------------------------------------------
  def change_emotion(path)
    #TODO
    #bmp = Bitmap.new(path)
    #@figure.bitmap.blt(x,y,w,h,bmp)
  end
  #--------------------------------------------------------------------------
  # ● 转换表情汉字到实际图像路径
  #--------------------------------------------------------------------------
  def get_emotion_path(str)
    #TODO
    path = ""
    return path
  end
  #--------------------------------------------------------------------------
  # ● 实际宽度
  #--------------------------------------------------------------------------
  def real_width
    return self.width - 2 * standard_padding
  end
  #--------------------------------------------------------------------------
  # ● 打开窗口并等待窗口开启完成
  #--------------------------------------------------------------------------
  def open_and_wait
    open
    test_mode
    Fiber.yield until open?
  end
  #--------------------------------------------------------------------------
  # ● 检查打开模式
  #--------------------------------------------------------------------------
  def test_mode
    result = 0
    if $game_message.has_text?
      text = $game_message.all_text.to_s.clone
      result = text.slice!(/^(\\mb|\\mn)/)
      case result
      when nil
        transform_style(0)
      when "\\mb"
        transform_style(obtain_escape_param(text))
      when "\\mn"
        transform_style(2)
        char_id = obtain_escape_param(text)
        if char_id > 0
          self.x = ($game_map.events[char_id].x + $game_map.display_x)*8
          self.y = ($game_map.events[char_id].y + $game_map.display_y)*8 + 16
        end
      end
      return
    end
    transform_style(0)
  end
end
=end