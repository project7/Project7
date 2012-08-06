#encoding:utf-8
#==============================================================================
# ■ Window_ItemList
#------------------------------------------------------------------------------
# 　物品画面中，显示持有物品的窗口。
#==============================================================================

class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @category = :none
    @data = []
    @comps = []
  end
  #--------------------------------------------------------------------------
  # ● 生成物品列表
  #--------------------------------------------------------------------------
  def make_item_list
    @data = $game_party.all_items.select {|item| include?(item) }
    @data.push(nil) if include?(nil)
    @comps.each do |c| c.dispose end
    @comps = []
  end
  #--------------------------------------------------------------------------
  # ● 捆綁繪制項目+添加點擊區
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    @comps.push Comp_Command.new(rect,self,index)
    
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item))
      draw_item_number(rect, item)
    end
  end
  #--------------------------------------------------------------------------
  # ● 捆綁x值
  #--------------------------------------------------------------------------
  def x=(new_x)
    delta = (new_x - self.x)
    @comps.each do |c| c.x += delta end
    super
  end
  #--------------------------------------------------------------------------
  # ● 捆綁y值
  #--------------------------------------------------------------------------
  def y=(new_y)
    delta = (new_y - self.y)
    @comps.each do |c| c.y += delta end
    super
  end
  #--------------------------------------------------------------------------
  # ● 捆綁z值
  #--------------------------------------------------------------------------
  def z=(new_z)
    @comps.each do |c| c.z = new_z+1 end
    super
  end
  #--------------------------------------------------------------------------
  # ● 捆綁光标向下移动
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    super
    mouse_upDown
  end
  #--------------------------------------------------------------------------
  # ● 捆綁光标向上移动
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    super
    mouse_upDown
  end
  #--------------------------------------------------------------------------
  # ● 捆綁光标向左移动
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    super
    mouse_leftRight
  end
  #--------------------------------------------------------------------------
  # ● 捆綁光标向右移动
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    super
    mouse_leftRight
  end
  #--------------------------------------------------------------------------
  # ● 捆綁釋放
  #--------------------------------------------------------------------------
  def dispose
    super
    @comps.each do |c| c.dispose end
  end
  #--------------------------------------------------------------------------
  # ● 接收信息
  #--------------------------------------------------------------------------
  def sendMSG(index,msg)
    case msg
    when :e
      self.active = true
      select(index)
    when :l
      self.active = false
      select(-1)
    when :c
      call_ok_handler
    end
  end
  #--------------------------------------------------------------------------
  # ● 鼠標上下移動
  #--------------------------------------------------------------------------
  def mouse_upDown
    rect = item_rect(index)
    pos = Mouse.get_pos
    return if pos.nil?
    y = rect.y+self.y+rect.height/2
    real_x = rect.x+self.x+12
    if pos[0] > real_x && pos[0] < real_x+rect.width
      x = pos[0]
    else
      x = real_x + rect.width/2
    end
    Mouse.set_pos(x,y)
  end
  #--------------------------------------------------------------------------
  # ● 鼠標左右移動
  #--------------------------------------------------------------------------
  def mouse_leftRight
    rect = item_rect(index)
    pos = Mouse.get_pos
    return if pos.nil?
    x = rect.x+self.x+rect.width/2
    real_y = rect.y+self.y+12
    if pos[0] > real_y && pos[0] < real_y+rect.height
      y = pos[0]
    else
      y = real_y + rect.height/2
    end
    Mouse.set_pos(x,y)
  end
end
