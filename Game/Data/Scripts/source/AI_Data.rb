class SB_AI < Battler_AI
  
  def initialize(user)
    @wait_count = 0
    @wait = false
    super
  end
  
  def get_action
    get_target
    return [4,0] unless @target
    return [4,0] unless $map_battle.last_action_state
    if @user.ap >= @user.get_ap_for_atk
      ssx = distance_x_from(@target.x)
      ssy = distance_y_from(@target.y)
      distance = ssx.abs+ssy.abs
      if distance < @user.atk_dis_min
        return away_from_character(@target.event)
      elsif distance > @user.atk_dis_max
        return toward_character(@target.event)
      elsif @user.atk_area[1]
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
    @target = $map_battle.top_hatred(@user.team)[0]
  end
  
end