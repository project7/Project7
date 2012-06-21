#encoding:utf-8
#==============================================================================
# ■ BattleManager
#------------------------------------------------------------------------------
# 　战斗过程的管理器。
#==============================================================================

module BattleManager
  #--------------------------------------------------------------------------
  # ● 设置
  #--------------------------------------------------------------------------
  def self.setup(troop_id, can_escape = true, can_lose = false)
    init_members
    $game_troop.setup(troop_id)
    @can_escape = can_escape
    @can_lose = can_lose
    make_escape_ratio
  end
  #--------------------------------------------------------------------------
  # ● 初始化成员
  #--------------------------------------------------------------------------
  def self.init_members
    @phase = :init              # 战斗阶段
    @can_escape = false         # 允许撤退的标志
    @can_lose = false           # 允许全灭的标志
    @event_proc = nil           # 事件用回调
    @preemptive = false         # 先制攻击的标志
    @surprise = false           # 被偷袭的标志
    @actor_index = -1           # 指令输入中的角色
    @action_forced = nil        # 强制的战斗行动
    @map_bgm = nil              # 战斗前的 BGM（记忆用）
    @map_bgs = nil              # 战斗前的 BGS（记忆用）
    @action_battlers = []       # 行动顺序列表
  end
  #--------------------------------------------------------------------------
  # ● 遇敌时的处理
  #--------------------------------------------------------------------------
  def self.on_encounter
    @preemptive = (rand < rate_preemptive)
    @surprise = (rand < rate_surprise && !@preemptive)
  end
  #--------------------------------------------------------------------------
  # ● 获取先制攻击的几率
  #--------------------------------------------------------------------------
  def self.rate_preemptive
    $game_party.rate_preemptive($game_troop.agi)
  end
  #--------------------------------------------------------------------------
  # ● 获取被偷袭的几率
  #--------------------------------------------------------------------------
  def self.rate_surprise
    $game_party.rate_surprise($game_troop.agi)
  end
  #--------------------------------------------------------------------------
  # ● 保存 BGM 和 BGS
  #--------------------------------------------------------------------------
  def self.save_bgm_and_bgs
    @map_bgm = RPG::BGM.last
    @map_bgs = RPG::BGS.last
  end
  #--------------------------------------------------------------------------
  # ● 播放战斗 BGM
  #--------------------------------------------------------------------------
  def self.play_battle_bgm
    $game_system.battle_bgm.play
    RPG::BGS.stop
  end
  #--------------------------------------------------------------------------
  # ● 播放战斗结束 ME
  #--------------------------------------------------------------------------
  def self.play_battle_end_me
    $game_system.battle_end_me.play
  end
  #--------------------------------------------------------------------------
  # ● 重播 BGM 和 BGS
  #--------------------------------------------------------------------------
  def self.replay_bgm_and_bgs
    @map_bgm.replay unless $BTEST
    @map_bgs.replay unless $BTEST
  end
  #--------------------------------------------------------------------------
  # ● 生成撤退成功率
  #--------------------------------------------------------------------------
  def self.make_escape_ratio
    @escape_ratio = 1.5 - 1.0 * $game_troop.agi / $game_party.agi
  end
  #--------------------------------------------------------------------------
  # ● 判定是否回合执行中
  #--------------------------------------------------------------------------
  def self.in_turn?
    @phase == :turn
  end
  #--------------------------------------------------------------------------
  # ● 判定是否回合结束
  #--------------------------------------------------------------------------
  def self.turn_end?
    @phase == :turn_end
  end
  #--------------------------------------------------------------------------
  # ● 判定是否中止战斗
  #--------------------------------------------------------------------------
  def self.aborting?
    @phase == :aborting
  end
  #--------------------------------------------------------------------------
  # ● 获取是否允许撤退
  #--------------------------------------------------------------------------
  def self.can_escape?
    @can_escape
  end
  #--------------------------------------------------------------------------
  # ● 获取指令输入中的角色
  #--------------------------------------------------------------------------
  def self.actor
    @actor_index >= 0 ? $game_party.members[@actor_index] : nil
  end
  #--------------------------------------------------------------------------
  # ● 清除指令输入中的角色
  #--------------------------------------------------------------------------
  def self.clear_actor
    @actor_index = -1
  end
  #--------------------------------------------------------------------------
  # ● 进行下一个指令输入
  #--------------------------------------------------------------------------
  def self.next_command
    begin
      if !actor || !actor.next_command
        @actor_index += 1
        return false if @actor_index >= $game_party.members.size
      end
    end until actor.inputable?
    return true
  end
  #--------------------------------------------------------------------------
  # ● 返回上一个指令输入
  #--------------------------------------------------------------------------
  def self.prior_command
    begin
      if !actor || !actor.prior_command
        @actor_index -= 1
        return false if @actor_index < 0
      end
    end until actor.inputable?
    return true
  end
  #--------------------------------------------------------------------------
  # ● 设置返回事件的回调用 Proc
  #--------------------------------------------------------------------------
  def self.event_proc=(proc)
    @event_proc = proc
  end
  #--------------------------------------------------------------------------
  # ● 设置等待用方法
  #--------------------------------------------------------------------------
  def self.method_wait_for_message=(method)
    @method_wait_for_message = method
  end
  #--------------------------------------------------------------------------
  # ● 等待信息显示的结束
  #--------------------------------------------------------------------------
  def self.wait_for_message
    @method_wait_for_message.call if @method_wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 战斗开始
  #--------------------------------------------------------------------------
  def self.battle_start
    $game_system.battle_count += 1
    $game_party.on_battle_start
    $game_troop.on_battle_start
    $game_troop.enemy_names.each do |name|
      $game_message.add(sprintf(Vocab::Emerge, name))
    end
    if @preemptive
      $game_message.add(sprintf(Vocab::Preemptive, $game_party.name))
    elsif @surprise
      $game_message.add(sprintf(Vocab::Surprise, $game_party.name))
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 中止战斗
  #--------------------------------------------------------------------------
  def self.abort
    @phase = :aborting
  end
  #--------------------------------------------------------------------------
  # ● 判定胜败
  #--------------------------------------------------------------------------
  def self.judge_win_loss
    if @phase
      return process_abort   if $game_party.members.empty?
      return process_defeat  if $game_party.all_dead?
      return process_victory if $game_troop.all_dead?
      return process_abort   if aborting?
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 胜利时的处理
  #--------------------------------------------------------------------------
  def self.process_victory
    play_battle_end_me
    replay_bgm_and_bgs
    $game_message.add(sprintf(Vocab::Victory, $game_party.name))
    display_exp
    gain_gold
    gain_drop_items
    gain_exp
    SceneManager.return
    battle_end(0)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 撤退时的处理
  #--------------------------------------------------------------------------
  def self.process_escape
    $game_message.add(sprintf(Vocab::EscapeStart, $game_party.name))
    success = @preemptive ? true : (rand < @escape_ratio)
    Sound.play_escape
    if success
      process_abort
    else
      @escape_ratio += 0.1
      $game_message.add('\.' + Vocab::EscapeFailure)
      $game_party.clear_actions
    end
    wait_for_message
    return success
  end
  #--------------------------------------------------------------------------
  # ● 中止时的处理
  #--------------------------------------------------------------------------
  def self.process_abort
    replay_bgm_and_bgs
    SceneManager.return
    battle_end(1)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 全灭时的处理
  #--------------------------------------------------------------------------
  def self.process_defeat
    $game_message.add(sprintf(Vocab::Defeat, $game_party.name))
    wait_for_message
    if @can_lose
      revive_battle_members
      replay_bgm_and_bgs
      SceneManager.return
    else
      SceneManager.goto(Scene_Gameover)
    end
    battle_end(2)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 复活参战角色（全灭时）
  #--------------------------------------------------------------------------
  def self.revive_battle_members
    $game_party.battle_members.each do |actor|
      actor.hp = 1 if actor.dead?
    end
  end
  #--------------------------------------------------------------------------
  # ● 战斗结束
  #     result : 结果（0:胜利 1:撤退 2:全灭）
  #--------------------------------------------------------------------------
  def self.battle_end(result)
    @phase = nil
    @event_proc.call(result) if @event_proc
    $game_party.on_battle_end
    $game_troop.on_battle_end
    SceneManager.exit if $BTEST
  end
  #--------------------------------------------------------------------------
  # ● 开始输入指令
  #--------------------------------------------------------------------------
  def self.input_start
    if @phase != :input
      @phase = :input
      $game_party.make_actions
      $game_troop.make_actions
      clear_actor
    end
    return !@surprise && $game_party.inputable?
  end
  #--------------------------------------------------------------------------
  # ● 回合开始
  #--------------------------------------------------------------------------
  def self.turn_start
    @phase = :turn
    clear_actor
    $game_troop.increase_turn
    make_action_orders
  end
  #--------------------------------------------------------------------------
  # ● 回合结束
  #--------------------------------------------------------------------------
  def self.turn_end
    @phase = :turn_end
    @preemptive = false
    @surprise = false
  end
  #--------------------------------------------------------------------------
  # ● 显示获得的经验值
  #--------------------------------------------------------------------------
  def self.display_exp
    if $game_troop.exp_total > 0
      text = sprintf(Vocab::ObtainExp, $game_troop.exp_total)
      $game_message.add('\.' + text)
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示获得的金钱
  #--------------------------------------------------------------------------
  def self.gain_gold
    if $game_troop.gold_total > 0
      text = sprintf(Vocab::ObtainGold, $game_troop.gold_total)
      $game_message.add('\.' + text)
      $game_party.gain_gold($game_troop.gold_total)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 显示获得的物品
  #--------------------------------------------------------------------------
  def self.gain_drop_items
    $game_troop.make_drop_items.each do |item|
      $game_party.gain_item(item, 1)
      $game_message.add(sprintf(Vocab::ObtainItem, item.name))
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 显示获得经验值和等级上升
  #--------------------------------------------------------------------------
  def self.gain_exp
    $game_party.all_members.each do |actor|
      actor.gain_exp($game_troop.exp_total)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 生成行动顺序
  #--------------------------------------------------------------------------
  def self.make_action_orders
    @action_battlers = []
    @action_battlers += $game_party.members unless @surprise
    @action_battlers += $game_troop.members unless @preemptive
    @action_battlers.each {|battler| battler.make_speed }
    @action_battlers.sort! {|a,b| b.speed - a.speed }
  end
  #--------------------------------------------------------------------------
  # ● 强制行动
  #--------------------------------------------------------------------------
  def self.force_action(battler)
    @action_forced = battler
    @action_battlers.delete(battler)
  end
  #--------------------------------------------------------------------------
  # ● 获取战斗行动的强制状态
  #--------------------------------------------------------------------------
  def self.action_forced?
    @action_forced != nil
  end
  #--------------------------------------------------------------------------
  # ● 获取强制行动的战斗者
  #--------------------------------------------------------------------------
  def self.action_forced_battler
    @action_forced
  end
  #--------------------------------------------------------------------------
  # ● 清除强制的战斗行动
  #--------------------------------------------------------------------------
  def self.clear_action_force
    @action_forced = nil
  end
  #--------------------------------------------------------------------------
  # ● 获取下一个行动角色
  #    获取处于行动顺序列表顶端的战斗者。
  #    没有获取角色时（index 为 nil, 或者战斗事件在战斗后发生）则跳过此行动。
  #--------------------------------------------------------------------------
  def self.next_subject
    loop do
      battler = @action_battlers.shift
      return nil unless battler
      next unless battler.index && battler.alive?
      return battler
    end
  end
end
