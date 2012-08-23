#encoding:utf-8
#==============================================================================
# ■ Window_Message
#------------------------------------------------------------------------------
# 　显示文字信息的窗口。
#==============================================================================

class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, window_height)
    self.z = 200
    self.openness = 0
    create_all_windows
    create_back_bitmap
    create_back_sprite
    clear_instance_variables
    @figure = Sprite.new
    
    @figure_nameback = Sprite.new
    @figure_nameback.bitmap = Cache.system("MUINameBack")
    @figure_nameback.z = z - 2
    @figure_nameback.visible = false
    
    @figure_name = Sprite.new
    @figure_name.z = z - 1
    @figure_name.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的宽度
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的高度
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # ● 清除实例变量
  #--------------------------------------------------------------------------
  def clear_instance_variables
    @fiber = nil                # 纤程
    @background = 0             # 背景类型
    @position = 2               # 显示位置
    clear_flags
  end
  #--------------------------------------------------------------------------
  # ● 清除的标志
  #--------------------------------------------------------------------------
  def clear_flags
    @show_fast = false          # 快进的标志
    @line_show_fast = false     # 行单位快进的标志
    @pause_skip = false         # “不等待输入”的标志
    @name = nil
  end
  #--------------------------------------------------------------------------
  # ● 获取显示行数
  #--------------------------------------------------------------------------
  def visible_line_number
    return 4
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_all_windows
    dispose_back_bitmap
    dispose_back_sprite
    @figure.dispose
    @figure_nameback.dispose
    @figure_name.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    update_all_windows
    update_back_sprite
    update_figure if @figure
    update_fiber
  end
  #--------------------------------------------------------------------------
  # ● 更新纤程
  #--------------------------------------------------------------------------
  def update_fiber
    if @fiber
      @fiber.resume
    elsif $game_message.busy? && !$game_message.scroll_mode
      @fiber = Fiber.new { fiber_main }
      @fiber.resume
    else
      $game_message.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成所有窗口
  #--------------------------------------------------------------------------
  def create_all_windows
    @gold_window = Window_Gold.new
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = 0
    @gold_window.openness = 0
    @choice_window = Window_ChoiceList.new(self)
    @number_window = Window_NumberInput.new(self)
    @item_window = Window_KeyItem.new(self)
  end
  #--------------------------------------------------------------------------
  # ● 生成背景位图
  #--------------------------------------------------------------------------
  def create_back_bitmap
    @back_bitmap = Cache.system("MUIBack")
    return
    @back_bitmap = Bitmap.new(width, height)
    rect1 = Rect.new(0, 0, width, 12)
    rect2 = Rect.new(0, 12, width, height - 24)
    rect3 = Rect.new(0, height - 12, width, 12)
    @back_bitmap.gradient_fill_rect(rect1, back_color2, back_color1, true)
    @back_bitmap.fill_rect(rect2, back_color1)
    @back_bitmap.gradient_fill_rect(rect3, back_color1, back_color2, true)
  end
  #--------------------------------------------------------------------------
  # ● 获取背景色 1
  #--------------------------------------------------------------------------
  def back_color1
    Color.new(0, 0, 0, 160)
  end
  #--------------------------------------------------------------------------
  # ● 获取背景色 2
  #--------------------------------------------------------------------------
  def back_color2
    Color.new(0, 0, 0, 0)
  end
  #--------------------------------------------------------------------------
  # ● 生成背景精灵
  #--------------------------------------------------------------------------
  def create_back_sprite
    @back_sprite = Sprite.new
    @back_sprite.bitmap = @back_bitmap
    @back_sprite.visible = false
    @back_sprite.z = z - 1
  end
  #--------------------------------------------------------------------------
  # ● 释放所有窗口
  #--------------------------------------------------------------------------
  def dispose_all_windows
    @gold_window.dispose
    @choice_window.dispose
    @number_window.dispose
    @item_window.dispose
    @figure.dispose
  end
  #--------------------------------------------------------------------------
  # ● 释放背景位图
  #--------------------------------------------------------------------------
  def dispose_back_bitmap
    @back_bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # ● 释放背景精灵
  #--------------------------------------------------------------------------
  def dispose_back_sprite
    @back_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新所有窗口
  #--------------------------------------------------------------------------
  def update_all_windows
    @gold_window.update
    @choice_window.update
    @number_window.update
    @item_window.update
  end
  #--------------------------------------------------------------------------
  # ● 更新背景精灵
  #--------------------------------------------------------------------------
  def update_back_sprite
    @back_sprite.visible = (@background == 0)
    @back_sprite.y = y
    @back_sprite.opacity = openness
    @back_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 处理纤程的主逻辑
  #--------------------------------------------------------------------------
  def fiber_main
    $game_message.visible = true
    update_background
    update_placement
    update_figure
    loop do
      process_all_text if $game_message.has_text?
      process_input
      $game_message.clear
      @gold_window.close
      Fiber.yield
      break unless text_continue?
    end
    dispose_figure
    dispose_name
    close_and_wait
    $game_message.visible = false
    @fiber = nil
  end
  
  #--------------------------------------------------------------------------
  # ● 创建立绘
  #--------------------------------------------------------------------------
  def create_figure
    @figure.bitmap = Cache.head(@name_file)
    @figure.z = z - 1
    @figure.mirror = @figure_position == 0
    if @figure_position == 1
      @figure.x = Graphics.width - @figure.bitmap.width
    else
      @figure.x = 0
    end
    @figure.y = Graphics.height - @figure.bitmap.height
  end
  def create_name
    @figure_nameback.visible = true
    if @name_file
      @figure_nameback.y = @figure.y
      if @figure_position == 1
        @figure_nameback.x = @figure.x - @figure_nameback.width / 2
      else
        @figure_nameback.x = @figure.width
      end
    else
      @figure_nameback.x = @figure_nameback.y = 0
    end
    
    @figure_name.visible = true
    @figure_name.bitmap = Bitmap.new 50, 200
    y = 0
    @name_text.chars.each do |i|
      h = @figure_name.bitmap.text_size(i).height
      @figure_name.bitmap.draw_text(0,y,50, h, i, 1)
      y += h
    end
    @figure_name.ox = @figure_name.bitmap.width / 2
    @figure_name.oy = y / 2
    @figure_name.x = @figure_nameback.x + @figure_nameback.width / 2
    @figure_name.y = @figure_nameback.y + @figure_nameback.height / 2
  end
  def translate_head
    @name_file = $game_temp.figure_map(@name)
    @figure_position = $game_temp.figurepos_map(@name) || 0
  end
  #--------------------------------------------------------------------------
  # ● 更新立绘
  #--------------------------------------------------------------------------
  def update_figure
    @figure.opacity = openness
    @figure.update
    
    @figure_name.opacity = openness
    @figure_name.update
    
    @figure_nameback.opacity = openness
    @figure_nameback.update
  end
  #--------------------------------------------------------------------------
  # ● 弃置立绘
  #--------------------------------------------------------------------------
  def dispose_figure
    @figure.bitmap = nil
  end
  def dispose_name
    @figure_nameback.visible = false
    @figure_name.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口背景
  #--------------------------------------------------------------------------
  def update_background
    @background = $game_message.background || 0
    self.opacity = @background == 0 ? 0 : 255
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口的位置
  #--------------------------------------------------------------------------
  def update_placement
    @position = $game_message.position || 0
    self.y = @position * (Graphics.height - height) / 2
    @gold_window.y = y > 0 ? 0 : Graphics.height - @gold_window.height
  end
  #--------------------------------------------------------------------------
  # ● 处理所有内容
  #--------------------------------------------------------------------------
  def process_all_text
    open_and_wait
    text = convert_escape_characters($game_message.all_text)
    @name = nil
    @name_text = nil
    text.gsub!(/^(.*?)(？?)：\n?/s) {
      @name = $1
      @name_text = $2 == "？" ? nil : @name
      nil
    }
    pos = {}
    new_page(text, pos)
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  #--------------------------------------------------------------------------
  # ● 输入处理
  #--------------------------------------------------------------------------
  def process_input
    if $game_message.choice?
      input_choice
    elsif $game_message.num_input?
      input_number
    elsif $game_message.item_choice?
      input_item
    else
      input_pause unless @pause_skip
    end
  end
  #--------------------------------------------------------------------------
  # ● 打开窗口并等待窗口开启完成
  #--------------------------------------------------------------------------
  def open_and_wait
    open
    Fiber.yield until open?
  end
  #--------------------------------------------------------------------------
  # ● 关闭窗口并等待窗口关闭完成
  #--------------------------------------------------------------------------
  def close_and_wait
    close
    Fiber.yield until all_close?
  end
  #--------------------------------------------------------------------------
  # ● 判定是否所有窗口已全部关闭
  #--------------------------------------------------------------------------
  def all_close?
    close? && @choice_window.close? &&
    @number_window.close? && @item_window.close?
  end
  #--------------------------------------------------------------------------
  # ● 判定文字是否继续显示
  #--------------------------------------------------------------------------
  def text_continue?
    $game_message.has_text? && !settings_changed?
  end
  #--------------------------------------------------------------------------
  # ● 判定背景和位置是否被更改
  #--------------------------------------------------------------------------
  def settings_changed?
    @background != $game_message.background ||
    @position != $game_message.position
  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def wait(duration)
    duration.times { Fiber.yield }
  end
  #--------------------------------------------------------------------------
  # ● 监听“确定”键的按下，更新快进的标志
  #--------------------------------------------------------------------------
  def update_show_fast
    @show_fast = true if CInput.trigger?($vkey[:Check]) || Mouse.down?(1)
  end
  #--------------------------------------------------------------------------
  # ● 输出一个字符后的等待
  #--------------------------------------------------------------------------
  def wait_for_one_character
    update_show_fast
    Fiber.yield unless @show_fast || @line_show_fast
  end
  #--------------------------------------------------------------------------
  # ● 翻页处理
  #--------------------------------------------------------------------------
  def new_page(text, pos)
    contents.clear
    if @name
      translate_head
      if @name_file
        create_figure
      else
        dispose_figure
      end
    end
    if @name_text
      create_name
    else
      dispose_name
    end
    draw_face($game_message.face_name || "", $game_message.face_index || 0, 0, 0)
    reset_font_settings
    pos[:x] = new_line_x
    pos[:y] = 0
    pos[:new_x] = new_line_x
    pos[:height] = calc_line_height(text)
    clear_flags
  end
  def process_character(c, text, pos)
    case c
    when "\r"   # 回车
      return
    when "\n"   # 换行
      process_new_line(text, pos)
    when "\f"   # 翻页
      process_new_page(text, pos)
    when "\e"   # 控制符
      process_escape_character(obtain_escape_code(text), text, pos)
    else        # 普通文字
      process_normal_character(c, text, pos)
    end
  end

  #--------------------------------------------------------------------------
  # ● 获取换行位置
  #--------------------------------------------------------------------------
  def new_line_x
    ($game_message.face_name || "").empty? ? 0 : 112
  end
  #--------------------------------------------------------------------------
  # ● 普通文字的处理
  #--------------------------------------------------------------------------
  def process_normal_character(c, text, pos)
    text_width = text_size(c).width
    if contents_width - pos[:x] > text_width
      draw_text(pos[:x], pos[:y], text_width * 2, pos[:height], c)
      pos[:x] += text_width
    else 
      process_new_line(text,pos)
      process_normal_character(c,text,pos)
    end
    wait_for_one_character
  end
  #--------------------------------------------------------------------------
  # ● 换行文字的处理
  #--------------------------------------------------------------------------
  def process_new_line(text, pos)
    @line_show_fast = false
    super
    if need_new_page?(text, pos)
      input_pause
      new_page(text, pos)
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定是否需要翻页
  #--------------------------------------------------------------------------
  def need_new_page?(text, pos)
    pos[:y] + pos[:height] > contents.height && !text.empty?
  end
  #--------------------------------------------------------------------------
  # ● 翻页文字的处理
  #--------------------------------------------------------------------------
  def process_new_page(text, pos)
    text.slice!(/^\n/)
    input_pause
    new_page(text, pos)
  end
  #--------------------------------------------------------------------------
  # ● 处理控制符指定的图标绘制
  #--------------------------------------------------------------------------
  def process_draw_icon(icon_index, pos)
    super
    wait_for_one_character
  end
  #--------------------------------------------------------------------------
  # ● 控制符的处理
  #     code : 控制符的实际形式（比如“\C[1]”是“C”）
  #     text : 绘制处理中的字符串缓存（字符串可能会被修改）
  #     pos  : 绘制位置 {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_escape_character(code, text, pos)
    case code.upcase
    when '$'
      @gold_window.open
    when '.'
      wait(15)
    when '|'
      wait(60)
    when '!'
      input_pause
    when '>'
      @line_show_fast = true
    when '<'
      @line_show_fast = false
    when '^'
      @pause_skip = true
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ● 处理输入等待
  #--------------------------------------------------------------------------
  def input_pause
    self.pause = true
    wait(10)
    Fiber.yield until CInput.trigger?($vkey[:X]) || CInput.trigger?($vkey[:Check]) || Mouse.down?(1) || Mouse.down?(2)
    CInput.update
    self.pause = false
  end
  #--------------------------------------------------------------------------
  # ● 处理选项的输入
  #--------------------------------------------------------------------------
  def input_choice
    @choice_window.start
    Fiber.yield while @choice_window.active
  end
  #--------------------------------------------------------------------------
  # ● 处理数值的输入
  #--------------------------------------------------------------------------
  def input_number
    @number_window.start
    Fiber.yield while @number_window.active
  end
  #--------------------------------------------------------------------------
  # ● 处理物品的选择
  #--------------------------------------------------------------------------
  def input_item
    @item_window.start
    Fiber.yield while @item_window.active
  end
end