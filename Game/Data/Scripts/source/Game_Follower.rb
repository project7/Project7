#encoding:utf-8
#==============================================================================
# ■ Game_Follower
#------------------------------------------------------------------------------
# 　管理跟随角色的类。处理跟随角色的显示、跟随的行为等。
#   请在 Game_Followers 类中查看具体的应用。
#==============================================================================

class Game_Follower < Game_Character
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(member_index, preceding_character)
    super()
    @member_index = member_index
    @preceding_character = preceding_character
    @transparent = $data_system.opt_transparent
    @through = true
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    @character_name = visible? ? actor.character_name : ""
    @character_index = visible? ? actor.character_index : 0
  end
  #--------------------------------------------------------------------------
  # ● 获取对应的角色
  #--------------------------------------------------------------------------
  def actor
    $game_party.battle_members[@member_index]
  end
  #--------------------------------------------------------------------------
  # ● 可视判定
  #--------------------------------------------------------------------------
  def visible?
    actor && $game_player.followers.visible
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    @move_speed     = $game_player.real_move_speed
    @transparent    = $game_player.transparent
    @walk_anime     = $game_player.walk_anime
    @step_anime     = $game_player.step_anime
    @direction_fix  = $game_player.direction_fix
    @opacity        = $game_player.opacity
    @blend_type     = $game_player.blend_type
    super
  end
  #--------------------------------------------------------------------------
  # ● 追随带队角色
  #--------------------------------------------------------------------------
  def chase_preceding_character
    unless moving?
      sx = distance_x_from(@preceding_character.x)
      sy = distance_y_from(@preceding_character.y)
      if sx != 0 && sy != 0
        move_diagonal(sx > 0 ? 4 : 6, sy > 0 ? 8 : 2)
      elsif sx != 0
        move_straight(sx > 0 ? 4 : 6)
      elsif sy != 0
        move_straight(sy > 0 ? 8 : 2)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定角色是否与领队同一位置
  #--------------------------------------------------------------------------
  def gather?
    !moving? && pos?(@preceding_character.x, @preceding_character.y)
  end
end
