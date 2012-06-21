#encoding:utf-8
#==============================================================================
# ■ Window_ChoiceList
#------------------------------------------------------------------------------
# 　此窗口使用于事件指令中的“显示选项”的功能。
#==============================================================================

class Window_ChoiceList < Window_Command
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(message_window)
    @message_window = message_window
    super(0, 0)
    self.openness = 0
    deactivate
  end
  #--------------------------------------------------------------------------
  # ● 开始输入的处理
  #--------------------------------------------------------------------------
  def start
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
    self.width = [max_choice_width + 12, 96].max + padding * 2
    self.width = [width, Graphics.width].min
    self.height = fitting_height($game_message.choices.size)
    self.x = Graphics.width - width
    if @message_window.y >= Graphics.height / 2
      self.y = @message_window.y - height
    else
      self.y = @message_window.y + @message_window.height
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取选项的最大宽度
  #--------------------------------------------------------------------------
  def max_choice_width
    $game_message.choices.collect {|s| text_size(s).width }.max
  end
  #--------------------------------------------------------------------------
  # ● 计算窗口内容的高度
  #--------------------------------------------------------------------------
  def contents_height
    item_max * item_height
  end
  #--------------------------------------------------------------------------
  # ● 生成指令列表
  #--------------------------------------------------------------------------
  def make_command_list
    $game_message.choices.each do |choice|
      add_command(choice, :choice)
    end
  end
  #--------------------------------------------------------------------------
  # ● 绘制项目
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect_for_text(index)
    draw_text_ex(rect.x, rect.y, command_name(index))
  end
  #--------------------------------------------------------------------------
  # ● 获取“取消处理”的有效状态
  #--------------------------------------------------------------------------
  def cancel_enabled?
    $game_message.choice_cancel_type > 0
  end
  #--------------------------------------------------------------------------
  # ● 调用“确定”的处理方法
  #--------------------------------------------------------------------------
  def call_ok_handler
    $game_message.choice_proc.call(index)
    close
  end
  #--------------------------------------------------------------------------
  # ● 调用“取消”的处理方法
  #--------------------------------------------------------------------------
  def call_cancel_handler
    $game_message.choice_proc.call($game_message.choice_cancel_type - 1)
    close
  end
end
