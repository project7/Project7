#encoding:utf-8
#==============================================================================
# ■ Scene_Debug
#------------------------------------------------------------------------------
# 　调试画面
#==============================================================================

class Scene_Debug < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    create_left_window
    create_right_window
    create_debug_help_window
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  def terminate
    super
    #$game_map.refresh
  end
  #--------------------------------------------------------------------------
  # ● 生成左窗口
  #--------------------------------------------------------------------------
  def create_left_window
    @left_window = Window_DebugLeft.new(0, 0)
    @left_window.set_handler(:ok,     method(:on_left_ok))
    @left_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # ● 生成右窗口
  #--------------------------------------------------------------------------
  def create_right_window
    wx = @left_window.width
    ww = Graphics.width - wx
    @right_window = Window_DebugRight.new(wx, 0, ww)
    @right_window.set_handler(:cancel, method(:on_right_cancel))
    @left_window.right_window = @right_window
  end
  #--------------------------------------------------------------------------
  # ● 生成帮助窗口
  #--------------------------------------------------------------------------
  def create_debug_help_window
    wx = @right_window.x
    wy = @right_window.height
    ww = @right_window.width
    wh = Graphics.height - wy
    @debug_help_window = Window_Base.new(wx, wy, ww, wh)
  end
  #--------------------------------------------------------------------------
  # ● 左“确定”
  #--------------------------------------------------------------------------
  def on_left_ok
    refresh_help_window
    @right_window.activate
    @right_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● 右“取消”
  #--------------------------------------------------------------------------
  def on_right_cancel
    @left_window.activate
    @right_window.unselect
    @debug_help_window.contents.clear
  end
  #--------------------------------------------------------------------------
  # ● 更新帮助窗口
  #--------------------------------------------------------------------------
  def refresh_help_window
    @debug_help_window.draw_text_ex(4, 0, help_text)
  end
  #--------------------------------------------------------------------------
  # ● 获取帮助字符串
  #--------------------------------------------------------------------------
  def help_text
    if @left_window.mode == :switch
      "C (Enter) : ON / OFF"
    else
      "← (Left)    :  -1\n" +
      "→ (Right)   :  +1\n" +
      "L (Pageup)   : -10\n" +
      "R (Pagedown) : +10"
    end
  end
end
