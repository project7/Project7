class Wait_buff < Buff
  
  attr_accessor :add_def

  def set_ele(user)
    @id = 1
    @user = user
    @name = "待机"
    @icon = "待机"
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
    @descr = "待机保持警惕\n物理防御力提高ap剩余百分比\n最多提高%50."
    @add_def = 0
  end

end

class Sick < Buff

  def set_ele(user)
    @id = 2
    @user = user
    @name = "毒"
    @icon = "中毒"
    @animation = []
    @keep_turn = 10
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
    @descr = "每回合损失最大生命值的%10\n持续10回合."
  end

end