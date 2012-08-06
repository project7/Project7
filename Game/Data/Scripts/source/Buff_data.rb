class Fuckme_buff < Buff

  def set_ele(user)
    @id = 1
    @name = "中毒"
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
  
  def set_extra
    @end_req = "buff.live_turn>=buff.keep_turn"
    @descr = "中毒者每回合损失1/5的生命."
  end
  
end