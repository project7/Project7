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
    if @wait_to_use
      a = @wait_to_use
      @wait_to_use = nil
      return [2,[a,[@target.x, @target.y]]]
    end
    if @user.ap >= @user.get_ap_for_atk
      ssx = distance_x_from(@target.x)
      ssy = distance_y_from(@target.y)
      distance = ssx.abs+ssy.abs
      @user.skill.each do |i|
        sick = i.enough_to_use(@user.ap,@user.hp,@user.sp)
        if sick==true && distance.between?(i.use_dis_min,i.use_dis_max)
          @wait_to_use = i
          do_effect_ready(i)
          @adapt_wait = true
          return nil
        end
      end
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
            return [1,[@target.x, @target.y]]
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
              return [1,[@target.x,@target.y]]
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

end