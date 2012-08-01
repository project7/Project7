module Fuc

  DIR_LIST = [[0,8,2],[4],[6]]# 方向表，方便计算
  SP_OPA = [255,100,150,255] # 透明度表，方便计算
  MOV_AREA_C = [Color.new(0,100,255,255),Color.new(0,150,255,255)]
  WAY_AREA_C = [Color.new(0,180,100,255),Color.new(100,200,50,255)]
  OPA_COLOR = Color.new(0,0,0,0)

# 寻路
  def self.sm(x,y)
    unless ($game_player.auto_move_path!=[] && x==@@last_x && y==@@last_y)
      astr = AStar.new($game_map,$game_player)
      astr.set_origin($game_player.x, $game_player.y)
      astr.set_target(x, y)
      $game_player.auto_move_path = astr.do_search
      @@last_x = x
      @@last_y = y
    end
  end
  
#战斗寻路
  def self.xxoo(x,y,dis,actor)
    astr = AStar.new($game_map,actor)
    astr.set_origin(actor.x, actor.y)
    astr.set_target(x, y)
    actor.auto_move_path = (astr.do_search)[0,dis]
    return actor.auto_move_path
  end
  
# 通过屏幕坐标获取游戏坐标
  def self.getpos_by_screenpos(pos)
    game_pos = [0,0]
    game_pos[0] = (pos[0]+$game_map.display_x*32).to_i/32
    game_pos[1] = (pos[1]+$game_map.display_y*32).to_i/32
    return game_pos
  end
  
  # 鼠标指向地板的选框
  def self.mouse_icon
    a = Bitmap.new(32,32)
    a.gradient_fill_rect(0, 0, 32, 32, Color.new(255,0,0,200), Color.new(180,120,0,200),true)
    a.gradient_fill_rect(1, 1, 30, 30, Color.new(180,120,0,150),Color.new(255,0,0,150),true)
    return a
  end

end