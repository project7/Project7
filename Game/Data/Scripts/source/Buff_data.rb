class Fuckme_buff < Buff

  def set_ele(user)
    @user = user
    @icon = nil
    @animation = []
    @keep_turn = 5
    @keep_step = 0
    @use_effect = ""
    @per_turn_start_effect = ""
    @per_step_effect = "actor.mag_damage(actor.maxhp/20)"
    @per_turn_end_effect = ""
  end
  
end