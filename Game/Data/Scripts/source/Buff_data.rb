#
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
    @per_act_effect = ""
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
    @per_act_effect = ""
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

class Tear < Buff
  
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
    @per_act_effect = ""
    @per_turn_end_effect = ""
    @end_effect = "a=self.god_damage(-buff.temp_damage[1]);
                   SceneManager.scene.spriteset.show_text(a[1].abs.to_s,self.event,Fuc::AP_COST_COLOR) if a[0]"
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
    @per_act_effect = ""
    @per_turn_end_effect = ""
    @end_effect = "self.die"
    @atk_effect = ""
    @b_damage_effect = ""
    @a_damage_effect = "@hp=[@hp,1].max;
                        a = buff.user.mag_damage(value);
                        SceneManager.scene.spriteset.show_text(a[1].abs.to_s,buff.user.event,Fuc::AP_ADD_COLOR) if a[0]"
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
    @per_act_effect = ""
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

class Catch < Buff
  
  attr_accessor :rem_skill

  def set_ele(user)
    @id = 6
    @user = user
    @name = "意念抛投"
    @icon = "ctrled"
    @animation = []
    @keep_turn = 0
    @keep_step = 0
    @use_effect = " new_buff.user.change_skill(new_buff.user.rskill);
                    new_buff.user.fake_skill.each_with_index{|i,j| new_buff.user.fake_skill[j]=FuckWithOutMoney.new if i.id==1;
                    new_buff.user.cal_skill_rem}"
    @per_turn_start_effect = ""
    @per_step_effect = ""
    @per_act_effect = ""
    @per_turn_end_effect = ""
    @end_effect = "buff.user.resc_skill"
    @atk_effect = ""
    @b_damage_effect = ""
    @a_damage_effect = ""
  end
  
  def set_extra
    @end_req = "@turn-buff.lived_turn>=buff.keep_turn"
    @descr = "该单位被人盯上了."
    @rem_skill = nil
  end
  
end

class ShutDown < Buff

  def set_ele(user)
    @id = 7
    @user = user
    @name = "眩晕"
    @icon = "ctrled"
    @animation = []
    @keep_turn = 2
    @keep_step = 0
    @use_effect = ""
    @per_turn_start_effect = "next_actor;ned_t=true"
    @per_step_effect = ""
    @per_act_effect = ""
    @per_turn_end_effect = ""
    @end_effect = ""
    @atk_effect = ""
    @b_damage_effect = ""
    @a_damage_effect = ""
  end
  
  def set_extra
    @end_req = "@turn-buff.lived_turn>=buff.keep_turn"
    @descr = "该单位无法行动."
  end
  
end

class OverFuck < Buff

  def set_ele(user)
    @id = 8
    @user = user
    @name = "竭心"
    @icon = "ctrled"
    @animation = []
    @keep_turn = 4
    @keep_step = 0
    @use_effect = ""
    @per_turn_start_effect = "next_actor;ned_t=true"
    @per_step_effect = ""
    @per_act_effect = ""
    @per_turn_end_effect = ""
    @end_effect = ""
    @atk_effect = ""
    @b_damage_effect = "value=value/2 if value<0"
    @a_damage_effect = ""
  end
  
  def set_extra
    @end_req = "@turn-buff.lived_turn>=buff.keep_turn"
    @descr = "该单位由于精力空虚而无法行动.\n并且受到的增益效果减半."
  end
  
end

class RefractionBuff < Buff

  def set_ele(user)
    @id = 9
    @user = user
    @name = "奥术分散"
    @icon = "ctrled"
    @animation = []
    @keep_turn = -1
    @keep_step = -1
    @use_effect = ""
    @per_turn_start_effect = ""
    @per_step_effect = ""
    @per_act_effect = ""
    @per_turn_end_effect = ""
    @end_effect = ""
    @atk_effect = ""
    @b_damage_effect = "if value>0
                          rdama = value*3/20;
                          value-=rdama;
                          value=@maxhp/2 if value>@maxhp/2;
                          $team_set.each do |zik|;
                            next if zik==self||zik.dead? || (zik.team&@team).size>0;
                            if (zik.x-self.x).abs+(zik.y-self.y).abs<=4;
                              a=zik.damage(rdama);
                              if a[0];
                                SceneManager.scene.spriteset.show_text(a[1].abs,zik.event,Fuc::HP_COST_COLOR,20) if a[1]>0;
                              elsif a[1]<=1;
                                SceneManager.scene.spriteset.show_text(Fuc::FAILD_ATTACK_TEXT[a[1]],zik.event);
                              end;
                            end;
                          end;
                        end"
    @a_damage_effect = ""
  end
  
  def set_extra
    @battle_end_not_clear = true
    @end_req = "false"
    @descr = "该单位无法被轻易击败."
  end
  
end

class DisturbBuff < Buff

  def set_ele(user)
    @id = 10
    @user = user
    @name = "奥术扰乱领域"
    @icon = "ctrled"
    @animation = []
    @keep_turn = -1
    @keep_step = -1
    @use_effect = ""
    @per_turn_start_effect = "$team_set.each do |pl|;
                                if !pl.dead? && (pl.team&@cur_actor.team).size==0 && !pl.ignore_magic;
                                  pl.add_buff(BeDisturbBuff.new(@cur_actor));
                                elsif pl!=buff.user;
                                  pl.dec_buff(10);
                                end;
                              end"
    @per_step_effect = ""
    @per_act_effect = ""
    @per_turn_end_effect = ""
    @end_effect = ""
    @atk_effect = ""
    @b_damage_effect = ""
    @a_damage_effect = ""
  end
  
  def set_extra
    @battle_end_not_clear = true
    @end_req = "false"
    @descr = "周围的能量将会被扭曲.\n敌人无法正常行动."
  end
  
end

class BeDisturbBuff < Buff

  def set_ele(user)
    @id = 10
    @user = user
    @name = "能量混乱"
    @icon = "ctrled"
    @animation = []
    @keep_turn = -1
    @keep_step = -1
    @use_effect = ""
    @per_turn_start_effect = ""
    @per_step_effect = ""
    @per_act_effect = " if !@cur_actor.ignore_magic&&id!=4&&(@cur_actor.x-buff.user.x).abs+(@cur_actor.y-buff.user.y).abs<=buff.user.int/15;
                          if $random_center.rand(100)<10;
                            @cur_actor.cost_ap_for(3,@cur_actor.maxap/2);
                            @last_action_state = false;
                            per_steps_cal;
                            return true;
                          end;
                        end"
    @per_turn_end_effect = ""
    @end_effect = ""
    @atk_effect = ""
    @b_damage_effect = ""
    @a_damage_effect = ""
  end
  
  def set_extra
    @end_req = "false"
    @descr = "该单位若是接近扰乱源.\n则无法正常行动."
  end
  
end

class SoulSwordBuff < Buff

  def set_ele(user)
    @id = 11
    @user = user
    @name = "灵魂连接"
    @icon = "ctrled"
    @animation = []
    @keep_turn = 0
    @keep_step = 0
    @use_effect = "new_buff.user.add_buff(SoulOwnerBuff.new(self))"
    @per_turn_start_effect = ""
    @per_step_effect = ""
    @per_act_effect = ""
    @per_turn_end_effect = ""
    @end_effect = ""
    @atk_effect = ""
    @b_damage_effect = ""
    @a_damage_effect = ""
  end
  
  def set_extra
    @end_req = "false"
    @descr = "该单位生死全由他人主宰."
  end
  
end

class SoulOwnerBuff < Buff

  def set_ele(user)
    @id = 12
    @user = user
    @name = "灵魂连接"
    @icon = "ctrled"
    @animation = []
    @keep_turn = 2
    @keep_step = 0
    @use_effect = ""
    @per_turn_start_effect = ""
    @per_step_effect = ""
    @per_act_effect = ""
    @per_turn_end_effect = ""
    @end_effect = "buff.user.dec_buff(11)"
    @atk_effect = ""
    @b_damage_effect = ""
    @a_damage_effect = "if (buff.user.team&@team).size>0;
                          a = buff.user.god_damage(-value.abs);
                          SceneManager.scene.spriteset.show_text(a[1],buff.user.event,Fuc::HP_ADD_COLOR,20) if a[0];
                        else;
                          a = buff.user.god_damage(value.abs);
                          SceneManager.scene.spriteset.show_text(a[1].abs,buff.user.event,Fuc::HP_COST_COLOR,20) if a[0];
                        end"
  end
  
  def set_extra
    @end_req = "@turn-buff.lived_turn>=buff.keep_turn"
    @descr = "该单位主宰着他人的生死."
  end
  
end

class BreakSelfBuff < Buff

  def set_ele(user)
    @id = 13
    @user = user
    @name = "挣脱"
    @icon = ""
    @animation = []
    @keep_turn = 0
    @keep_step = 0
    @use_effect = " if new_buff.user==self;
                      kick_buff = @buff.select{|smbuf| smbuf!=new_buff&&!smbuf.battle_end_not_clear}.map{|ss| ss.id};
                      kick_rate = [60-kick_buff.size*10,20].max;
                      if $random_center.rand(1) < kick_rate;
                        kick_buff.each{|fbuff| self.dec_buff(fbuff)};
                        SceneManager.scene.spriteset.show_text(\"成功!\",self.event,Fuc::SP_ADD_COLOR,20);
                      else;
                        SceneManager.scene.spriteset.show_text(\"失败!\",self.event,Fuc::SP_ADD_COLOR,20);
                      end;
                    end;
                    new_buff.user.dec_buff(13)"
    @per_turn_start_effect = ""
    @per_step_effect = ""
    @per_act_effect = ""
    @per_turn_end_effect = ""
    @end_effect = ""
    @atk_effect = ""
    @b_damage_effect = ""
    @a_damage_effect = ""
  end
  
  def set_extra
    @end_req = "true"
    @descr = "该单位正在挣扎."
  end
  
end

class MultAttackBuff < Buff

  def set_ele(user)
    @id = 14
    @user = user
    @name = "连斩"
    @icon = "ctrled"
    @animation = []
    @keep_turn = -1
    @keep_step = -1
    @use_effect = ""
    @per_turn_start_effect = ""
    @per_step_effect = ""
    @per_act_effect = ""
    @per_turn_end_effect = ""
    @end_effect = ""
    @atk_effect = " if i==temp[-1] && $random_center.rand(100)<75;
                      @cur_actor.cost_ap_for(3,-@cur_actor.get_ap_for_atk);
                      @cur_actor.auto_skill=[\"if !@mtk;@cur_actor.event.cantmove=true;@mtk=0;end;if @mtk>30;@mtk=nil;true;else;@mtk+=1;false;end\",para,\"@cur_actor.event.cantmove=false;@cur_actor.cost_ap_for(1)\"];
                    else;
                      @cur_actor.event.cantmove=false;
                    end"
    @b_damage_effect = ""
    @a_damage_effect = ""
  end
  
  def set_extra
    @battle_end_not_clear = true
    @end_req = "false"
    @descr = "该单位在攻击后有概率继续攻击."
  end
  
end

class KingdomBuff < Buff
  
  attr_accessor :can_eff
  attr_accessor :kturn

  def set_ele(user)
    @id = 15
    @user = user
    @name = "存在"
    @icon = "ctrled"
    @animation = []
    @keep_turn = -1
    @keep_step = -1
    @use_effect = "self.ignore_dmg_rate += 25"
    @per_turn_start_effect = ""
    @per_step_effect = ""
    @per_act_effect = ""
    @per_turn_end_effect = "buff.kturn-=1 if !buff.can_eff && buff.kturn>0"
    @end_effect = "self.ignore_dmg_rate -= 25"
    @atk_effect = ""
    @b_damage_effect = ""
    @a_damage_effect = "if @hp<=0 && buff.kturn>0;
                          @hp=[1,@hp].max;
                          buff.can_eff=false;
                        end"
  end
  
  def set_extra
    @can_eff = true
    @kturn = 4
    @battle_end_not_clear = true
    @end_req = "false"
    @descr = "该单位有概率闪避任何伤害.\n并且刚韧不屈."
  end
  
  def refresh
    @can_eff = true
    @kturn = 4
  end
  
end