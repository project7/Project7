#==============================================================================
# ■ Mouse
#==============================================================================
module CMouse
  CursorFile = "Graphics/System/Cursor.cur"       # 光标文件名(最好包含后缀)
  EmptyCursor = "Graphics/System/Empty.cur"        #空光标
  AttackCursor = "Graphics/System/Attack.cur"        # 攻击光标
  LKEY = 1
  RKEY = 2
  MKEY = 4
  module_function
  #--------------------------------------------------------------------------
  # ## 获取坐标
  #--------------------------------------------------------------------------
  def pos
    return [self.x, self.y]
  end
  #--------------------------------------------------------------------------
  # ## 在区域内?
  #--------------------------------------------------------------------------
  def area?(x, y, width, height)
    pos = [self.x, self.y]
    return false if pos.nil?
    return false unless pos[0].between?(x, x+width)
    return false unless pos[1].between?(y, y+height)
    return true
  end
  #--------------------------------------------------------------------------
  # ## 在区域内?
  #--------------------------------------------------------------------------
  def rect?(rect)
    pos = [self.x, self.y]
    return false if pos.nil?
    return false unless pos[0].between?(rect.x, rect.x+rect.width)
    return false unless pos[1].between?(rect.y, rect.y+rect.height)
    return true
  end
  
  set_cursor(CursorFile)
end
Mouse=CMouse