class OrzAI < Battler_AI
  
  def initialize(user)
    @adapt_wait = true
    @wait_count = 0
    @wait = false
    super
  end
  
  def get_action
    get_target
    return [4,0] unless @target
    if !$map_battle.last_action_state || ($map_battle.last_action_state.is_a?(Array) && !$map_battle.last_action_state[0] && $map_battle.last_action_state[1]>1)
      @wait_count= 60
      $map_battle.last_action_state = true
      return [4,0] 
    end
    if @adapt_wait
      @wait_count += 1
      if @wait_count > 60
        @adapt_wait = false
        @wait_count = 0
      end
      return nil
    end
    if @user.ap >= @user.get_ap_for_atk
      ssx = distance_x_from(@target.x)
      ssy = distance_y_from(@target.y)
      distance = ssx.abs+ssy.abs
      if (distance > @user.atk_dis_min)
        return toward_character(@target.event)
      elsif @user.atk_area[1]
        if @wait
          if @wait_count < 60
            @wait_count+=1
            return nil
          else
            @wait_count = 0
            @wait = false
            return fuck @target.x, @target.y
          end
        else
          do_attack_ready
          @wait = true
          return nil
        end
      else
        if ssx==0||ssy==0
          if @wait
            if @wait_count < 60
              @wait_count+=1
              return nil
            else
              @wait_count = 0
              @wait = false
              return fuck @target.x, @target.y
            end
          else
            do_attack_ready
            @wait = true
            return nil
          end
        end
        if ssx.abs<ssy.abs
          return [0,ssx<0 ? 6 : 4]
        else
          return [0,ssy<0 ? 2 : 8]
        end
      end
    elsif @user.atk_dis_min>1
      do_attack_end
      return away_from_character(@target.event)
    else
      return [4,0]
    end
    return nil
  end
  
  def get_target
    @target = $map_battle.top_hatred(@user)[0]
  end
  
  def fuck x, y
    skill = @user.skill
    if skill != [] && skill.size > 0
      rnd = $random_center.rand(skill.size + 2)
      if rnd < 2
        return [1,[x, y]]
      else
        sk = skill[rnd-3]
        if sk.enough_to_use(@user.ap,@user.hp,@user.sp)
          return [2,[sk, [x + ($random_center.rand(2) == 1 ? 1 : - 1), y + ($random_center.rand(2) == 1 ? 1 : - 1)]]]
        else
          return fuck x, y
        end
      end
    else
      return [1,[x, y]]
    end
  end
end