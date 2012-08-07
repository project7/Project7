class Battler_AI
  
  def initialize(user)
    @user = user
  end
  
  def get_action
    return [4,0]
  end
  
  def do_attack_ready
    $map_battle.set_view_pos(@user.x,@user.y)
    $map_battle.movearea.dispose if $map_battle.movearea
    $map_battle.create_enablearea
    if @user.atk_area[1]
      $map_battle.create_effectarea
    else
      $map_battle.create_effectarea(@target)
    end
    $map_battle.effectarea.x = @target.x
    $map_battle.effectarea.y = @target.y
    SceneManager.scene.spriteset.fillup[0].visible = false
    SceneManager.scene.spriteset.fillup[3].x = $map_battle.effectarea.screen_x
    SceneManager.scene.spriteset.fillup[3].y = $map_battle.effectarea.screen_y
  end
  
  def do_attack_end
    $map_battle.set_view_pos(@user.x,@user.y)
    $map_battle.create_maparea
    $map_battle.effectarea.dispose if $map_battle.effectarea
    $map_battle.enablearea.dispose if $map_battle.enablearea
  end

  def toward_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if sx.abs > sy.abs
      dir = sx > 0 ? 4 : 6
      if @user.event.passable?(@user.x, @user.y, dir)
        return [0,dir]
      elsif sy != 0
        dir = sy > 0 ? 8 : 2
        if @user.event.passable?(@user.x, @user.y, dir)
          return [0,dir]
        end
      else
        return [0,$random_center.rand(10)<5 ? 8 : 2]
      end
    elsif sy != 0
      dir = sy > 0 ? 8 : 2
      if @user.event.passable?(@user.x, @user.y, dir)
        return [0,dir]
      elsif sx != 0
        dir = sx > 0 ? 4 : 6
        if @user.event.passable?(@user.x, @user.y, dir)
          return [0,dir]
        end
      else
        return [0,$random_center.rand(10)<5 ? 4 : 6]
      end
    end
    return [4,0]
  end

  def away_from_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if sx.abs > sy.abs
      dir = sx > 0 ? 6 : 4
      if @user.event.passable?(@user.x, @user.y, dir)
        return [0,dir]
      elsif sy != 0
        dir = sy > 0 ? 2 : 8
        if @user.event.passable?(@user.x, @user.y, dir)
          return [0,dir]
        end
      else
        return [0,$random_center.rand(10)<5 ? 2 : 8]
      end
    elsif sy != 0
      dir = sy > 0 ? 2 : 8
      if @user.event.passable?(@user.x, @user.y, dir)
        return [0,dir]
      elsif sx != 0
        dir = sx > 0 ? 6 : 4
        if @user.event.passable?(@user.x, @user.y, dir)
          return [0,dir]
        end
      else
        return [0,$random_center.rand(10)<5 ? 6 : 4]
      end
    end
    return [4,0]
  end
  
  def distance_x_from(x)
    result = @user.event.x - x
    if $game_map.loop_horizontal? && result.abs > $game_map.width / 2
      if result < 0
        result += $game_map.width
      else
        result -= $game_map.width
      end
    end
    return result
  end

  def distance_y_from(y)
    result = @user.event.y - y
    if $game_map.loop_vertical? && result.abs > $game_map.height / 2
      if result < 0
        result += $game_map.height
      else
        result -= $game_map.height
      end
    end
    return result
  end
  
end