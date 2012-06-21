#encoding:utf-8
#==============================================================================
# ■ Window_DebugRight
#------------------------------------------------------------------------------
# 　调试画面中，调节开关和变量值的窗口。
#==============================================================================

class Window_DebugRight < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :mode                     # 模式（:switch / :variable）
  attr_reader   :top_id                   # 顶端 ID 
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #-------------------------------------------------------------------------
  def initialize(x, y, width)
    super(x, y, width, fitting_height(10))
    @mode = :switch
    @top_id = 1
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 获取项目数
  #--------------------------------------------------------------------------
  def item_max
    return 10
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # ● 绘制项目
  #--------------------------------------------------------------------------
  def draw_item(index)
    data_id = @top_id + index
    id_text = sprintf("%04d:", data_id)
    id_width = text_size(id_text).width
    if @mode == :switch
      name = $data_system.switches[data_id]
      status = $game_switches[data_id] ? "[ON]" : "[OFF]"
    else
      name = $data_system.variables[data_id]
      status = $game_variables[data_id]
    end
    name = "" unless name
    rect = item_rect_for_text(index)
    change_color(normal_color)
    draw_text(rect, id_text)
    rect.x += id_width
    rect.width -= id_width + 60
    draw_text(rect, name)
    rect.width += 60
    draw_text(rect, status, 2)
  end
  #--------------------------------------------------------------------------
  # ● 设置模式
  #     mode : 新的模式
  #--------------------------------------------------------------------------
  def mode=(mode)
    if @mode != mode
      @mode = mode
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置新的顶端 ID 
  #     id : 新的 ID
  #--------------------------------------------------------------------------
  def top_id=(id)
    if @top_id != id
      @top_id = id
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取选中的 ID 
  #--------------------------------------------------------------------------
  def current_id
    top_id + index
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    update_switch_mode   if active && mode == :switch
    update_variable_mode if active && mode == :variable
  end
  #--------------------------------------------------------------------------
  # ● 更新开关模式
  #--------------------------------------------------------------------------
  def update_switch_mode
    if Input.trigger?(:C)
      Sound.play_ok
      $game_switches[current_id] = !$game_switches[current_id]
      redraw_current_item
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新变量模式
  #--------------------------------------------------------------------------
  def update_variable_mode
    return unless $game_variables[current_id].is_a?(Numeric)
    value = $game_variables[current_id]
    value += 1 if Input.repeat?(:RIGHT)
    value -= 1 if Input.repeat?(:LEFT)
    value += 10 if Input.repeat?(:R)
    value -= 10 if Input.repeat?(:L)
    if $game_variables[current_id] != value
      $game_variables[current_id] = value
      Sound.play_cursor
      redraw_current_item
    end
  end
end
