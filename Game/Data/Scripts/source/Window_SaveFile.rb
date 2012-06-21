#encoding:utf-8
#==============================================================================
# ■ Window_SaveFile
#------------------------------------------------------------------------------
# 　存档画面和读档画面中显示存档文件的窗口。
#==============================================================================

class Window_SaveFile < Window_Base
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :selected                 # 选择状态
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #     index : 存档文件的索引
  #--------------------------------------------------------------------------
  def initialize(height, index)
    super(0, index * height, Graphics.width, height)
    @file_index = index
    refresh
    @selected = false
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(normal_color)
    name = Vocab::File + " #{@file_index + 1}"
    draw_text(4, 0, 200, line_height, name)
    @name_width = text_size(name).width
    draw_party_characters(152, 58)
    draw_playtime(0, contents.height - line_height, contents.width - 4, 2)
  end
  #--------------------------------------------------------------------------
  # ● 绘制队伍角色
  #--------------------------------------------------------------------------
  def draw_party_characters(x, y)
    header = DataManager.load_header(@file_index)
    return unless header
    header[:characters].each_with_index do |data, i|
      draw_character(data[0], data[1], x + i * 48, y)
    end
  end
  #--------------------------------------------------------------------------
  # ● 绘制游戏时间
  #--------------------------------------------------------------------------
  def draw_playtime(x, y, width, align)
    header = DataManager.load_header(@file_index)
    return unless header
    draw_text(x, y, width, line_height, header[:playtime_s], 2)
  end
  #--------------------------------------------------------------------------
  # ● 设置选择状态
  #--------------------------------------------------------------------------
  def selected=(selected)
    @selected = selected
    update_cursor
  end
  #--------------------------------------------------------------------------
  # ● 更新光标
  #--------------------------------------------------------------------------
  def update_cursor
    if @selected
      cursor_rect.set(0, 0, @name_width + 8, line_height)
    else
      cursor_rect.empty
    end
  end
end
