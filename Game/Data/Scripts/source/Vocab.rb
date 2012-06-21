#encoding:utf-8
#==============================================================================
# ■ Vocab
#------------------------------------------------------------------------------
#  定义了用语和信息。将部分资料定义为常量。用语部分来自于 $data_system 。
#==============================================================================

module Vocab

  # 商店画面
  ShopBuy         = "买入"
  ShopSell        = "卖出"
  ShopCancel      = "取消"
  Possession      = "持有数"

  # 状态画面
  ExpTotal        = "当前经验"
  ExpNext         = "下一%s"

  # 存档／读档画面
  SaveMessage     = "在哪个位置保存存档？"
  LoadMessage     = "从哪个位置读取存档？"
  File            = "存档"

  # 有多个队友时显示
  PartyName       = "%s的队伍"
  
  # 战斗基本信息
  Emerge          = "%s出现了！"
  Preemptive      = "%s先发制人！"
  Surprise        = "%s被偷袭了！"
  EscapeStart     = "%s准备撤退！"
  EscapeFailure   = "但是被包围了……"

  # 战斗结束信息
  Victory         = "%s胜利了！"
  Defeat          = "%s全灭了……"
  ObtainExp       = "获得了%s点经验值！"
  ObtainGold      = "获得了%s\\G！"
  ObtainItem      = "获得了%s！"
  LevelUp         = "%s已经%s%s了！"
  ObtainSkill     = "领悟了%s！"

  # 物品使用
  UseItem         = "%s使用了%s！"

  # 关键一击
  CriticalToEnemy = "关键一击！"
  CriticalToActor = "痛恨一击！"

  # 角色对象的行动结果
  ActorDamage     = "%s受到了%s点的伤害！"
  ActorRecovery   = "%s的%s恢复了%s点！"
  ActorGain       = "%s的%s恢复了%s点！"
  ActorLoss       = "%s的%s失去了%s点！"
  ActorDrain      = "%s的%s被夺走了%s点！"
  ActorNoDamage   = "%s没有受到伤害！"
  ActorNoHit      = "失误！%s毫发无伤！"

  # 敌人对象的行动结果
  EnemyDamage     = "%s受到了%s点的伤害！"
  EnemyRecovery   = "%s的%s恢复了%s点！"
  EnemyGain       = "%s的%s恢复了%s点！"
  EnemyLoss       = "%s的%s失去了%s点！"
  EnemyDrain      = "%s的%s被夺走了%s点！"
  EnemyNoDamage   = "%s没有受到伤害！"
  EnemyNoHit      = "失误！%s毫发无伤！"

  # 回避／反射
  Evasion         = "%s躲开了攻击！"
  MagicEvasion    = "%s抵消了魔法效果！"
  MagicReflection = "%s反射了魔法效果！"
  CounterAttack   = "%s进行反击！"
  Substitute      = "%s代替%s承受了攻击！"

  # 能力强化／弱化
  BuffAdd         = "%s的%s上升了！"
  DebuffAdd       = "%s的%s下降了！"
  BuffRemove      = "%s的%s恢复了！"

  # 技能或物品的使用无效时
  ActionFailure   = "对%s无效！"

  # 出错时的信息
  PlayerPosError  = "没有设置玩家的初始位置。"
  EventOverflow   = "调用的公共事件超过过上限。"

  # 基本状态
  def self.basic(basic_id)
    $data_system.terms.basic[basic_id]
  end

  # 能力
  def self.param(param_id)
    $data_system.terms.params[param_id]
  end

  # 装备类型
  def self.etype(etype_id)
    $data_system.terms.etypes[etype_id]
  end

  # 指令
  def self.command(command_id)
    $data_system.terms.commands[command_id]
  end

  # 货币单位
  def self.currency_unit
    $data_system.currency_unit
  end

  #--------------------------------------------------------------------------
  def self.level;       basic(0);     end   # 等级
  def self.level_a;     basic(1);     end   # 等级(缩写)
  def self.hp;          basic(2);     end   # HP
  def self.hp_a;        basic(3);     end   # HP(缩写)
  def self.mp;          basic(4);     end   # MP
  def self.mp_a;        basic(5);     end   # MP(缩写)
  def self.tp;          basic(6);     end   # TP
  def self.tp_a;        basic(7);     end   # TP(缩写)
  def self.fight;       command(0);   end   # 战斗
  def self.escape;      command(1);   end   # 撤退
  def self.attack;      command(2);   end   # 攻击
  def self.guard;       command(3);   end   # 防御
  def self.item;        command(4);   end   # 物品
  def self.skill;       command(5);   end   # 技能
  def self.equip;       command(6);   end   # 装备
  def self.status;      command(7);   end   # 状态
  def self.formation;   command(8);   end   # 整队
  def self.save;        command(9);   end   # 存档
  def self.game_end;    command(10);  end   # 结束游戏
  def self.weapon;      command(12);  end   # 武器
  def self.armor;       command(13);  end   # 护甲
  def self.key_item;    command(14);  end   # 贵重物品
  def self.equip2;      command(15);  end   # 更换装备
  def self.optimize;    command(16);  end   # 最强装备
  def self.clear;       command(17);  end   # 全部卸下
  def self.new_game;    command(18);  end   # 开始游戏
  def self.continue;    command(19);  end   # 继续游戏
  def self.shutdown;    command(20);  end   # 退出游戏
  def self.to_title;    command(21);  end   # 返回标题
  def self.cancel;      command(22);  end   # 取消
  #--------------------------------------------------------------------------
end
