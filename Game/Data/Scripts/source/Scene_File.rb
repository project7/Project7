#encoding:utf-8
#==============================================================================
# ■ Scene_File
#------------------------------------------------------------------------------
# 　存档画面和读档画面共同的父类
#==============================================================================

class Scene_File < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_savefile_viewport
    create_savefile_windows
    init_selection
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  def terminate
    super
    @savefile_viewport.dispose
    @savefile_windows.each { |window| window.dispose }
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    @savefile_windows.each { |window| window.update }
    update_savefile_selection
  end
  #--------------------------------------------------------------------------
  # ● 生成帮助窗口
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new(1)
    @help_window.set_text(help_window_text)
  end
  #--------------------------------------------------------------------------
  # ● 获取帮助窗口的文本
  #--------------------------------------------------------------------------
  def help_window_text
    return ""
  end
  #--------------------------------------------------------------------------
  # ● 生成存档文件显示端口
  #--------------------------------------------------------------------------
  def create_savefile_viewport
    @savefile_viewport = Viewport.new
    @savefile_viewport.rect.y = @help_window.height
    @savefile_viewport.rect.height -= @help_window.height
  end
  #--------------------------------------------------------------------------
  # ● 生成存档文件窗口
  #--------------------------------------------------------------------------
  def create_savefile_windows
    @savefile_windows = Array.new(item_max) do |i|
      Window_SaveFile.new(savefile_height, i)
    end
    @savefile_windows.each { |window| window.viewport = @savefile_viewport }
  end
  #--------------------------------------------------------------------------
  # ● 初始化选择状态
  #--------------------------------------------------------------------------
  def init_selection
    @index = first_savefile_index
    @savefile_windows[@index].selected = true
    self.top_index = @index - visible_max / 2
    ensure_cursor_visible
  end
  #--------------------------------------------------------------------------
  # ● 获取项目数
  #--------------------------------------------------------------------------
  def item_max
    DataManager.savefile_max
  end
  #--------------------------------------------------------------------------
  # ● 获取可显示的存档数目
  #--------------------------------------------------------------------------
  def visible_max
    return 4
  end
  #--------------------------------------------------------------------------
  # ● 获取存档文件窗口的高度
  #--------------------------------------------------------------------------
  def savefile_height
    @savefile_viewport.rect.height / visible_max
  end
  #--------------------------------------------------------------------------
  # ● 获取开始时文件索引的位置
  #--------------------------------------------------------------------------
  def first_savefile_index
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 获取当前索引
  #--------------------------------------------------------------------------
  def index
    @index
  end
  #--------------------------------------------------------------------------
  # ● 获取顶端索引
  #--------------------------------------------------------------------------
  def top_index
    @savefile_viewport.oy / savefile_height
  end
  #--------------------------------------------------------------------------
  # ● 设置顶端索引
  #--------------------------------------------------------------------------
  def top_index=(index)
    index = 0 if index < 0
    index = item_max - visible_max if index > item_max - visible_max
    @savefile_viewport.oy = index * savefile_height
  end
  #--------------------------------------------------------------------------
  # ● 获取末端索引
  #--------------------------------------------------------------------------
  def bottom_index
    top_index + visible_max - 1
  end
  #--------------------------------------------------------------------------
  # ● 设置末端索引
  #--------------------------------------------------------------------------
  def bottom_index=(index)
    self.top_index = index - (visible_max - 1)
  end
  #--------------------------------------------------------------------------
  # ● 更新存档文件选择
  #--------------------------------------------------------------------------
  def update_savefile_selection
    return on_savefile_ok     if Input.trigger?(:C)
    return on_savefile_cancel if Input.trigger?(:B)
    update_cursor
  end
  #--------------------------------------------------------------------------
  # ● 存档文件“确定”
  #--------------------------------------------------------------------------
  def on_savefile_ok
  end
  #--------------------------------------------------------------------------
  # ● 存档文件“取消”
  #--------------------------------------------------------------------------
  def on_savefile_cancel
    Sound.play_cancel
    return_scene
  end
  #--------------------------------------------------------------------------
  # ● 更新光标
  #--------------------------------------------------------------------------
  def update_cursor
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_pagedown   if Input.trigger?(:R)
    cursor_pageup     if Input.trigger?(:L)
    if @index != last_index
      Sound.play_cursor
      @savefile_windows[last_index].selected = false
      @savefile_windows[@index].selected = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 光标向下移动
  #--------------------------------------------------------------------------
  def cursor_down(wrap)
    @index = (@index + 1) % item_max if @index < item_max - 1 || wrap
    ensure_cursor_visible
  end
  #--------------------------------------------------------------------------
  # ● 光标向上移动
  #--------------------------------------------------------------------------
  def cursor_up(wrap)
    @index = (@index - 1 + item_max) % item_max if @index > 0 || wrap
    ensure_cursor_visible
  end
  #--------------------------------------------------------------------------
  # ● 光标移至下 1 页
  #--------------------------------------------------------------------------
  def cursor_pagedown
    if top_index + visible_max < item_max
      self.top_index += visible_max
      @index = [@index + visible_max, item_max - 1].min
    end
  end
  #--------------------------------------------------------------------------
  # ● 光标移至上 1 页
  #--------------------------------------------------------------------------
  def cursor_pageup
    if top_index > 0
      self.top_index -= visible_max
      @index = [@index - visible_max, 0].max
    end
  end
  #--------------------------------------------------------------------------
  # ● 确保光标在画面范围内滚动
  #--------------------------------------------------------------------------
  def ensure_cursor_visible
    self.top_index = index if index < top_index
    self.bottom_index = index if index > bottom_index
  end
end
