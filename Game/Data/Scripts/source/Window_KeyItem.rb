#encoding:utf-8
#==============================================================================
# ■ Window_KeyItem
#------------------------------------------------------------------------------
# 　此窗口使用于事件指令中的“选择物品”功能。
#==============================================================================

class Window_KeyItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(message_window)
    @message_window = message_window
    super(0, 0, Graphics.width, fitting_height(4))
    self.openness = 0
    deactivate
    set_handler(:ok,     method(:on_ok))
    set_handler(:cancel, method(:on_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 开始输入的处理
  #--------------------------------------------------------------------------
  def start
    self.category = :key_item
    update_placement
    refresh
    select(0)
    open
    activate
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口的位置
  #--------------------------------------------------------------------------
  def update_placement
    if @message_window.y >= Graphics.height / 2
      self.y = 0
    else
      self.y = Graphics.height - height
    end
  end
  #--------------------------------------------------------------------------
  # ● 确定时的处理
  #--------------------------------------------------------------------------
  def on_ok
    result = item ? item.id : 0
    $game_variables[$game_message.item_choice_variable_id] = result
    close
  end
  #--------------------------------------------------------------------------
  # ● 取消时的处理
  #--------------------------------------------------------------------------
  def on_cancel
    $game_variables[$game_message.item_choice_variable_id] = 0
    close
  end
end
