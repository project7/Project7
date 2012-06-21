#encoding:utf-8
#==============================================================================
# ■ Window_Status
#------------------------------------------------------------------------------
# 　状态画面中，显示角色基本信息的窗口。
#==============================================================================

class Window_Status < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 0, Graphics.width, Graphics.height)
    @actor = actor
    refresh
    activate
  end
  #--------------------------------------------------------------------------
  # ● 设置角色
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_block1   (line_height * 0)
    draw_horz_line(line_height * 1)
    draw_block2   (line_height * 2)
    draw_horz_line(line_height * 6)
    draw_block3   (line_height * 7)
    draw_horz_line(line_height * 13)
    draw_block4   (line_height * 14)
  end
  #--------------------------------------------------------------------------
  # ● 绘制区域 1 
  #--------------------------------------------------------------------------
  def draw_block1(y)
    draw_actor_name(@actor, 4, y)
    draw_actor_class(@actor, 128, y)
    draw_actor_nickname(@actor, 288, y)
  end
  #--------------------------------------------------------------------------
  # ● 绘制区域 2 
  #--------------------------------------------------------------------------
  def draw_block2(y)
    draw_actor_face(@actor, 8, y)
    draw_basic_info(136, y)
    draw_exp_info(304, y)
  end
  #--------------------------------------------------------------------------
  # ● 绘制区域 3 
  #--------------------------------------------------------------------------
  def draw_block3(y)
    draw_parameters(32, y)
    draw_equipments(288, y)
  end
  #--------------------------------------------------------------------------
  # ● 绘制区域 4 
  #--------------------------------------------------------------------------
  def draw_block4(y)
    draw_description(4, y)
  end
  #--------------------------------------------------------------------------
  # ● 绘制水平线
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
    line_y = y + line_height / 2 - 1
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
  end
  #--------------------------------------------------------------------------
  # ● 获取水平线的颜色
  #--------------------------------------------------------------------------
  def line_color
    color = normal_color
    color.alpha = 48
    color
  end
  #--------------------------------------------------------------------------
  # ● 绘制基本信息
  #--------------------------------------------------------------------------
  def draw_basic_info(x, y)
    draw_actor_level(@actor, x, y + line_height * 0)
    draw_actor_icons(@actor, x, y + line_height * 1)
    draw_actor_hp(@actor, x, y + line_height * 2)
    draw_actor_mp(@actor, x, y + line_height * 3)
  end
  #--------------------------------------------------------------------------
  # ● 绘制能力值
  #--------------------------------------------------------------------------
  def draw_parameters(x, y)
    6.times {|i| draw_actor_param(@actor, x, y + line_height * i, i + 2) }
  end
  #--------------------------------------------------------------------------
  # ● 绘制经验值信息
  #--------------------------------------------------------------------------
  def draw_exp_info(x, y)
    s1 = @actor.max_level? ? "-------" : @actor.exp
    s2 = @actor.max_level? ? "-------" : @actor.next_level_exp - @actor.exp
    s_next = sprintf(Vocab::ExpNext, Vocab::level)
    change_color(system_color)
    draw_text(x, y + line_height * 0, 180, line_height, Vocab::ExpTotal)
    draw_text(x, y + line_height * 2, 180, line_height, s_next)
    change_color(normal_color)
    draw_text(x, y + line_height * 1, 180, line_height, s1, 2)
    draw_text(x, y + line_height * 3, 180, line_height, s2, 2)
  end
  #--------------------------------------------------------------------------
  # ● 绘制装备
  #--------------------------------------------------------------------------
  def draw_equipments(x, y)
    @actor.equips.each_with_index do |item, i|
      draw_item_name(item, x, y + line_height * i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 绘制说明
  #--------------------------------------------------------------------------
  def draw_description(x, y)
    draw_text_ex(x, y, @actor.description)
  end
end
