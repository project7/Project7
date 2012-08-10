class Wait_buff < Buff
  
  attr_accessor :add_def

  def set_ele(user)
    @id = 1
    @user = user
    @name = "待机"
    @icon = "wait"
    @animation = []
    @keep_turn = 1
    @keep_step = 0
    @use_effect = "new_buff.add_def=[self.def*(self.ap*100/self.maxap)/100,self.def/2].min;
                  self.def_add+=new_buff.add_def"
    @per_turn_start_effect = ""
    @per_step_effect = ""
    @per_turn_end_effect = ""
    @end_effect = "self.def_add-=buff.add_def"
    @atk_effect = ""
    @damage_effect = ""
  end
  
  def set_extra
    @end_req = "@turn-buff.lived_turn>=buff.keep_turn"
    @descr = "待机保持警惕\n物理防御力提高ap剩余百分比\n最多提高%50.\n持续1回合."
    @add_def = 0
  end

end

class Sick < Buff

  def set_ele(user)
    @id = 2
    @user = user
    @name = "毒"
    @icon = "shit_damage"
    @animation = []
    @keep_turn = 3
    @keep_step = 0
    @use_effect = ""
    @per_turn_start_effect = "a=@cur_actor.mag_damage(@cur_actor.maxhp/10);
                              @splink.show_text(a[1].to_s,@cur_actor.event,DAMGE_GREEN) if a[0]"
    @per_step_effect = ""
    @per_turn_end_effect = ""
    @end_effect = ""
    @atk_effect = ""
    @damage_effect = ""
  end
  
  def set_extra
    @end_req = "@turn-buff.lived_turn>=buff.keep_turn"
    @descr = "每回合损失最大生命值的%10\n持续3回合."
  end

end

class Weak < Buff
  
  attr_accessor :temp_damage

  def set_ele(user)
    @id = 3
    @user = user
    @name = "撕裂"
    @icon = "weak"
    @animation = []
    @keep_turn = 2
    @keep_step = 0
    @use_effect = ""
    @per_turn_start_effect = "buff.temp_damage=@cur_actor.mag_damage(@cur_actor.hp/4);
                              @splink.show_text(buff.temp_damage[1].to_s,@cur_actor.event,AP_ADD_COLOR) if buff.temp_damage[0]"
    @per_step_effect = "a=@cur_actor.mag_damage(@cur_actor.get_ap_for_step);
                            @splink.show_text(a[1].to_s,@cur_actor.event,AP_ADD_COLOR) if a[0]"
    @per_turn_end_effect = "a=@cur_actor.god_damage(buff.temp_damage[1]);
                            @splink.show_text(a[1].to_s,@cur_actor.event,AP_COST_COLOR) if a[0]"
    @end_effect = ""
    @atk_effect = ""
    @damage_effect = ""
  end
  
  def set_extra
    @end_req = "@turn-buff.lived_turn>=buff.keep_turn"
    @descr = "每回合开始时损失25%的当前生命.\n每进行一次动作损失行走所需行动力的生命值.\n回合结束时,回复回合开始时损失的生命.\n持续2回合"
    @temp_damage = 0
  end

end