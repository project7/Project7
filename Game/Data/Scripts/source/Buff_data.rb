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
    @b_damage_effect = ""
    @a_damage_effect = ""
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
    @per_turn_start_effect = "a=@cur_actor.mag_damage(@cur_actor.hp/5);
                              @splink.show_text(a[1].to_s,@cur_actor.event,DAMGE_GREEN) if a[0]"
    @per_step_effect = ""
    @per_turn_end_effect = ""
    @end_effect = ""
    @atk_effect = ""
    @b_damage_effect = ""
    @a_damage_effect = ""
  end
  
  def set_extra
    @end_req = "@turn-buff.lived_turn>=buff.keep_turn"
    @descr = "每回合损失当前生命值的%20\n持续3回合."
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
    @use_effect = "new_buff.temp_damage=self.damage(self.hp/4);
                   SceneManager.scene.spriteset.show_text(new_buff.temp_damage[1].to_s,self.event,Fuc::AP_ADD_COLOR) if new_buff.temp_damage[0]"
    @per_turn_start_effect = ""
    @per_step_effect = "a=@cur_actor.mag_damage(@cur_actor.get_ap_for_step*10);
                            @splink.show_text(a[1].to_s,@cur_actor.event,AP_ADD_COLOR) if a[0]"
    @per_turn_end_effect = ""
    @end_effect = "a=self.god_damage(-buff.temp_damage[1]);
                   SceneManager.scene.spriteset.show_text(a[1].to_s,self.event,Fuc::AP_COST_COLOR) if a[0]"
    @atk_effect = ""
    @b_damage_effect = ""
    @a_damage_effect = ""
  end
  
  def set_extra
    @end_req = "@turn-buff.lived_turn>=buff.keep_turn"
    @descr = "被附加时损失25%的当前生命.\n每进行一次动作损失行走所需行动力十倍的生命值.\nbuff效果消失时,回复开始时损失的生命.\n开始和结束的回复与伤害效果无视魔法免疫.\n持续2回合"
    @temp_damage = 0
  end

end

class Ctrled < Buff
  
  attr_accessor :temp_damage

  def set_ele(user)
    @id = 4
    @user = user
    @name = "被操控"
    @icon = "ctrled"
    @animation = []
    @keep_turn = 2
    @keep_step = 0
    @use_effect = ""
    @per_turn_start_effect = ""
    @per_step_effect = ""
    @per_turn_end_effect = ""
    @end_effect = "self.die"
    @atk_effect = ""
    @b_damage_effect = "@hp=[@hp,1].max;
                        a = buff.user.mag_damage(value);
                        SceneManager.scene.spriteset.show_text(a[1].to_s,buff.user.event,Fuc::AP_ADD_COLOR) if a[0]"
    @a_damage_effect = ""
  end
  
  def set_extra
    @end_req = "@turn-buff.lived_turn>=buff.keep_turn"
    @descr = "该单位死亡后被操控.\n无法被杀死.\n所受伤害由施法者承担.\n持续2回合."
    @temp_damage = 0
  end

end

class Deep_Damage < Buff
  
  attr_accessor :rem_damage

  def set_ele(user)
    @id = 5
    @user = user
    @name = "伤害加深"
    @icon = "ctrled"
    @animation = []
    @keep_turn = 2
    @keep_step = 0
    @use_effect = ""
    @per_turn_start_effect = ""
    @per_step_effect = ""
    @per_turn_end_effect = ""
    @end_effect = ""
    @atk_effect = ""
    @b_damage_effect = "if $map_battle.cur_actor==buff.user;value+=buff.rem_damage;buff.rem_damage+=30;end"
    @a_damage_effect = ""
  end
  
  def set_extra
    @end_req = "@turn-buff.lived_turn>=buff.keep_turn"
    @descr = "该单位每次被施法者攻击.\n都会受到30点更多的伤害.\n可无限叠加.\n持续2回合."
    @rem_damage = 0
  end

end