module Fuc
# 寻路
  def self.sm(x,y)
    astr = AStar.new($game_map)
    astr.set_origin($game_player.x, $game_player.y)
    astr.set_target(x, y)
    $game_map.auto_move_path = astr.do_search
  end
  
end