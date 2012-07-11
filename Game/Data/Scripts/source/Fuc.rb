module Fuc

  DIR_LIST = [[0,8,2],[4],[6]]# 方向表，方便计算

# 寻路
  def self.sm(x,y)
    unless ($game_player.auto_move_path!=[] && x==@@last_x && y==@@last_y)
      astr = AStar.new($game_map)
      astr.set_origin($game_player.x, $game_player.y)
      astr.set_target(x, y)
      $game_player.auto_move_path = astr.do_search
      @@last_x = x
      @@last_y = y
    end
  end
  
# 通过屏幕坐标获取游戏坐标
  def self.getpos_by_screenpos(pos)
    game_pos = [0,0]
    game_pos[0] = (pos[0]+$game_map.display_x*32).to_i/32
    game_pos[1] = (pos[1]+$game_map.display_y*32).to_i/32
    return game_pos
  end

end