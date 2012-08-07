class Fux < Battler_AI
  
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
      distance = distance_x_from(@target.x).abs+distance_y_from(@target.y).abs
      if distance < @user.atk_dis_min
        return away_from_character(@target.event)
      elsif distance > @user.atk_dis_max
        return toward_character(@target.event)
      else
        if @wait
          if @wait_count < 60
            @wait_count+=1
          else
            @wait_count = 0
            @wait = false
            return [1,[@target.x,@target.y]]
          end
        else
          do_attack_ready
          @wait = true
        end
      end
    else
      do_attack_end
      return away_from_character(@target.event)
    end
    return nil
  end
  
  def get_target
    @target = $map_battle.top_hatred(@user.team)[0]
  end
  
end