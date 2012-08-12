class Skill

  attr_accessor :id                                 #ID
  attr_accessor :name                               #技能名称
  attr_accessor :init_skill                         #是否主动技能
  attr_accessor :icon                               #技能小图标
  attr_accessor :user_animation                     #使用者动画
  attr_accessor :use_dis_min                        #最小释放距离
  attr_accessor :use_dis_max                        #最大释放距离
  attr_accessor :hotkey                             #热键
  attr_accessor :target_partner_animation           #友方击中动画
  attr_accessor :target_enemy_animation             #敌人击中动画
  attr_accessor :target_p_dead_animation            #友方尸体被击中动画
  attr_accessor :target_e_dead_animation            #敌方尸体被击中动画
  attr_accessor :use_req                            #技能使用条件(eval)
  attr_accessor :hurt_enemy                         #是否作用于敌人
  attr_accessor :hurt_partner                       #是否作用于友方
  attr_accessor :hurt_p_dead                        #是否作用于友军尸体
  attr_accessor :hurt_e_dead                        #是否作用于敌方尸体
  attr_accessor :hurt_nothing                       #是否作用于空地
  attr_accessor :hurt_cant_move                     #是否作用于不可移动地区
  attr_accessor :hurt_area                          #作用范围
  attr_accessor :hurt_maxnum                        #最大作用单位数
  attr_accessor :sp_cost                            #消耗sp
  attr_accessor :hp_cost                            #消耗hp
  attr_accessor :ap_cost                            #消耗ap
  attr_accessor :hp_damage                          #生命伤害(魔法)
  attr_accessor :sp_damage                          #法力燃烧
  attr_accessor :ap_damage                          #行动力伤害
  attr_accessor :buff                               #附加buff
  attr_accessor :debuff                             #抵抗buff
  attr_accessor :descr                              #技能描述
  attr_accessor :spec_effect                        #特殊效果(eval)
  attr_accessor :sp_cost_rate                       #按百分比消耗sp
  attr_accessor :hp_cost_rate                       #按百分比消耗hp
  attr_accessor :ap_cost_rate                       #按百分比消耗ap
  attr_accessor :level                              #技能等级
  attr_accessor :hp_damage_add                      #hp伤害增加(eval)
  attr_accessor :sp_damage_add                      #sp伤害增加(eval)
  attr_accessor :ap_damage_add                      #ap伤害增加(eval)
  attr_accessor :ignore_mag_det                     #无视魔法免疫
  
  def initialize
    set_ui
    set_ele
    set_extra
    set_other
  end
  
  def set_ui
    @icon = nil
    @user_animation = 0
    @target_partner_animation = 0
    @target_enemy_animation = 0
    @target_p_dead_animation = 0
    @target_e_dead_animation = 0
  end
  
  def set_ele
    @id = 0
    @name = ""
    @init_skill = true
    @use_req = "true"
    @use_dis_min = 0
    @use_dis_max = 0
    @hotkey = nil
    @hurt_enemy = true
    @hurt_partner = false
    @hurt_p_dead = false
    @hurt_e_dead = false
    @hurt_nothing = false
    @hurt_cant_move = false
    @hurt_area = nil
    @hurt_maxnum = 1
    @sp_cost = 1
    @hp_cost = 0
    @ap_cost = 0
    @hp_damage = 1
    @sp_damage = 0
    @ap_damage = 0
    @buff = []
    @debuff = []
    @descr = ""
  end
  
  def set_other
    @use_in_battle = true
    @use_in_scene = false
  end
  
  def set_extra
    @spec_effect = ""
    @sp_cost_rate = 0
    @hp_cost_rate = 0
    @ap_cost_rate = 0
    @level = 0
    @hp_damage_add = "skill.level*100"
    @sp_damage_add = "skill.level*50"
    @ap_damage_add = "0"
    @ignore_mag_det = false
  end
  
  def enough_to_use(ap,hp,sp)
    if ap>=@ap_cost
      if hp> @hp_cost
        if sp>=@sp_cost
          if can_use
            if instance_eval(@use_req)
              return true
            else
              return 0
            end
          else
            return 1
          end
        else
          return 3
        end
      else
        return 4
      end
    else
      return 5
    end
  end
  
  def can_use
    return false unless @init_skill
    return false if $map_battle && !@use_in_battle
    return false if !$map_battle && !@use_in_scene
    return true
  end
  
end