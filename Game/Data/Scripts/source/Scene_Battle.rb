#encoding:utf-8
#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　战斗画面
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    create_spriteset
    create_all_windows
    BattleManager.method_wait_for_message = method(:wait_for_message)
  end
  #--------------------------------------------------------------------------
  # ● 开始后处理
  #--------------------------------------------------------------------------
  def post_start
    super
    battle_start
  end
  #--------------------------------------------------------------------------
  # ● 结束前处理
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    Graphics.fadeout(30) if SceneManager.scene_is?(Scene_Map)
    Graphics.fadeout(60) if SceneManager.scene_is?(Scene_Title)
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_spriteset
    @info_viewport.dispose
    RPG::ME.stop
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    if BattleManager.in_turn?
      process_event
      process_action
    end
    BattleManager.judge_win_loss
  end
  #--------------------------------------------------------------------------
  # ● 更新画面（基础）
  #--------------------------------------------------------------------------
  def update_basic
    super
    $game_timer.update
    $game_troop.update
    @spriteset.update
    update_info_viewport
    update_message_open
  end
  #--------------------------------------------------------------------------
  # ● 更新画面（等待用）
  #--------------------------------------------------------------------------
  def update_for_wait
    update_basic
  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def wait(duration)
    duration.times {|i| update_for_wait if i < duration / 2 || !show_fast? }
  end
  #--------------------------------------------------------------------------
  # ● 快进判定
  #--------------------------------------------------------------------------
  def show_fast?
    Input.press?(:A) || Input.press?(:C)
  end
  #--------------------------------------------------------------------------
  # ● 等待（快进无效）
  #--------------------------------------------------------------------------
  def abs_wait(duration)
    duration.times {|i| update_for_wait }
  end
  #--------------------------------------------------------------------------
  # ● 短时间等待（快进无效）
  #--------------------------------------------------------------------------
  def abs_wait_short
    abs_wait(15)
  end
  #--------------------------------------------------------------------------
  # ● 等待信息显示的结束
  #--------------------------------------------------------------------------
  def wait_for_message
    @message_window.update
    update_for_wait while $game_message.visible
  end
  #--------------------------------------------------------------------------
  # ● 等待动画显示的结束
  #--------------------------------------------------------------------------
  def wait_for_animation
    update_for_wait
    update_for_wait while @spriteset.animation?
  end
  #--------------------------------------------------------------------------
  # ● 等待效果执行的结束
  #--------------------------------------------------------------------------
  def wait_for_effect
    update_for_wait
    update_for_wait while @spriteset.effect?
  end
  #--------------------------------------------------------------------------
  # ● 更新信息显示的显示端口
  #--------------------------------------------------------------------------
  def update_info_viewport
    move_info_viewport(0)   if @party_command_window.active
    move_info_viewport(128) if @actor_command_window.active
    move_info_viewport(64)  if BattleManager.in_turn?
  end
  #--------------------------------------------------------------------------
  # ● 移动信息显示的显示端口
  #--------------------------------------------------------------------------
  def move_info_viewport(ox)
    current_ox = @info_viewport.ox
    @info_viewport.ox = [ox, current_ox + 16].min if current_ox < ox
    @info_viewport.ox = [ox, current_ox - 16].max if current_ox > ox
  end
  #--------------------------------------------------------------------------
  # ● 信息窗口打开时的更新
  #    在状态窗口关闭完成前，信息窗口的打开度设置为 0 。
  #--------------------------------------------------------------------------
  def update_message_open
    if $game_message.busy? && !@status_window.close?
      @message_window.openness = 0
      @status_window.close
      @party_command_window.close
      @actor_command_window.close
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成精灵组
  #--------------------------------------------------------------------------
  def create_spriteset
    @spriteset = Spriteset_Battle.new
  end
  #--------------------------------------------------------------------------
  # ● 释放精灵组
  #--------------------------------------------------------------------------
  def dispose_spriteset
    @spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # ● 生成所有窗口
  #--------------------------------------------------------------------------
  def create_all_windows
    create_message_window
    create_scroll_text_window
    create_log_window
    create_status_window
    create_info_viewport
    create_party_command_window
    create_actor_command_window
    create_help_window
    create_skill_window
    create_item_window
    create_actor_window
    create_enemy_window
  end
  #--------------------------------------------------------------------------
  # ● 生成信息窗口
  #--------------------------------------------------------------------------
  def create_message_window
    @message_window = Window_Message.new
  end
  #--------------------------------------------------------------------------
  # ● 生成滚动文字窗口
  #--------------------------------------------------------------------------
  def create_scroll_text_window
    @scroll_text_window = Window_ScrollText.new
  end
  #--------------------------------------------------------------------------
  # ● 生成日志记录窗口
  #--------------------------------------------------------------------------
  def create_log_window
    @log_window = Window_BattleLog.new
    @log_window.method_wait = method(:wait)
    @log_window.method_wait_for_effect = method(:wait_for_effect)
  end
  #--------------------------------------------------------------------------
  # ● 生成状态窗口
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_BattleStatus.new
    @status_window.x = 128
  end
  #--------------------------------------------------------------------------
  # ● 生成信息显示的显示端口
  #--------------------------------------------------------------------------
  def create_info_viewport
    @info_viewport = Viewport.new
    @info_viewport.rect.y = Graphics.height - @status_window.height
    @info_viewport.rect.height = @status_window.height
    @info_viewport.z = 100
    @info_viewport.ox = 64
    @status_window.viewport = @info_viewport
  end
  #--------------------------------------------------------------------------
  # ● 生成队伍指令窗口
  #--------------------------------------------------------------------------
  def create_party_command_window
    @party_command_window = Window_PartyCommand.new
    @party_command_window.viewport = @info_viewport
    @party_command_window.set_handler(:fight,  method(:command_fight))
    @party_command_window.set_handler(:escape, method(:command_escape))
    @party_command_window.unselect
  end
  #--------------------------------------------------------------------------
  # ● 生成角色指令窗口
  #--------------------------------------------------------------------------
  def create_actor_command_window
    @actor_command_window = Window_ActorCommand.new
    @actor_command_window.viewport = @info_viewport
    @actor_command_window.set_handler(:attack, method(:command_attack))
    @actor_command_window.set_handler(:skill,  method(:command_skill))
    @actor_command_window.set_handler(:guard,  method(:command_guard))
    @actor_command_window.set_handler(:item,   method(:command_item))
    @actor_command_window.set_handler(:cancel, method(:prior_command))
    @actor_command_window.x = Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● 生成帮助窗口
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new
    @help_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 生成技能窗口
  #--------------------------------------------------------------------------
  def create_skill_window
    @skill_window = Window_BattleSkill.new(@help_window, @info_viewport)
    @skill_window.set_handler(:ok,     method(:on_skill_ok))
    @skill_window.set_handler(:cancel, method(:on_skill_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 生成物品窗口
  #--------------------------------------------------------------------------
  def create_item_window
    @item_window = Window_BattleItem.new(@help_window, @info_viewport)
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 生成角色窗口
  #--------------------------------------------------------------------------
  def create_actor_window
    @actor_window = Window_BattleActor.new(@info_viewport)
    @actor_window.set_handler(:ok,     method(:on_actor_ok))
    @actor_window.set_handler(:cancel, method(:on_actor_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 生成敌人窗口
  #--------------------------------------------------------------------------
  def create_enemy_window
    @enemy_window = Window_BattleEnemy.new(@info_viewport)
    @enemy_window.set_handler(:ok,     method(:on_enemy_ok))
    @enemy_window.set_handler(:cancel, method(:on_enemy_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 更新状态窗口的信息
  #--------------------------------------------------------------------------
  def refresh_status
    @status_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 进行下一个指令输入
  #--------------------------------------------------------------------------
  def next_command
    if BattleManager.next_command
      start_actor_command_selection
    else
      turn_start
    end
  end
  #--------------------------------------------------------------------------
  # ● 返回上一个指令输入
  #--------------------------------------------------------------------------
  def prior_command
    if BattleManager.prior_command
      start_actor_command_selection
    else
      start_party_command_selection
    end
  end
  #--------------------------------------------------------------------------
  # ● 开始队伍指令的选择
  #--------------------------------------------------------------------------
  def start_party_command_selection
    unless scene_changing?
      refresh_status
      @status_window.unselect
      @status_window.open
      if BattleManager.input_start
        @actor_command_window.close
        @party_command_window.setup
      else
        @party_command_window.deactivate
        turn_start
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 指令“战斗”
  #--------------------------------------------------------------------------
  def command_fight
    next_command
  end
  #--------------------------------------------------------------------------
  # ● 指令“撤退”
  #--------------------------------------------------------------------------
  def command_escape
    turn_start unless BattleManager.process_escape
  end
  #--------------------------------------------------------------------------
  # ● 开始角色指令的选择
  #--------------------------------------------------------------------------
  def start_actor_command_selection
    @status_window.select(BattleManager.actor.index)
    @party_command_window.close
    @actor_command_window.setup(BattleManager.actor)
  end
  #--------------------------------------------------------------------------
  # ● 指令“攻击”
  #--------------------------------------------------------------------------
  def command_attack
    BattleManager.actor.input.set_attack
    select_enemy_selection
  end
  #--------------------------------------------------------------------------
  # ● 指令“技能”
  #--------------------------------------------------------------------------
  def command_skill
    @skill_window.actor = BattleManager.actor
    @skill_window.stype_id = @actor_command_window.current_ext
    @skill_window.refresh
    @skill_window.show.activate
  end
  #--------------------------------------------------------------------------
  # ● 指令“防御”
  #--------------------------------------------------------------------------
  def command_guard
    BattleManager.actor.input.set_guard
    next_command
  end
  #--------------------------------------------------------------------------
  # ● 指令“物品”
  #--------------------------------------------------------------------------
  def command_item
    @item_window.refresh
    @item_window.show.activate
  end
  #--------------------------------------------------------------------------
  # ● 开始选择队友
  #--------------------------------------------------------------------------
  def select_actor_selection
    @actor_window.refresh
    @actor_window.show.activate
  end
  #--------------------------------------------------------------------------
  # ● 角色“确定”
  #--------------------------------------------------------------------------
  def on_actor_ok
    BattleManager.actor.input.target_index = @actor_window.index
    @actor_window.hide
    @skill_window.hide
    @item_window.hide
    next_command
  end
  #--------------------------------------------------------------------------
  # ● 角色“取消”
  #--------------------------------------------------------------------------
  def on_actor_cancel
    @actor_window.hide
    case @actor_command_window.current_symbol
    when :skill
      @skill_window.activate
    when :item
      @item_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # ● 开始选择敌人
  #--------------------------------------------------------------------------
  def select_enemy_selection
    @enemy_window.refresh
    @enemy_window.show.activate
  end
  #--------------------------------------------------------------------------
  # ● 敌人“确定”
  #--------------------------------------------------------------------------
  def on_enemy_ok
    BattleManager.actor.input.target_index = @enemy_window.enemy.index
    @enemy_window.hide
    @skill_window.hide
    @item_window.hide
    next_command
  end
  #--------------------------------------------------------------------------
  # ● 敌人“取消”
  #--------------------------------------------------------------------------
  def on_enemy_cancel
    @enemy_window.hide
    case @actor_command_window.current_symbol
    when :attack
      @actor_command_window.activate
    when :skill
      @skill_window.activate
    when :item
      @item_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # ● 技能“确定”
  #--------------------------------------------------------------------------
  def on_skill_ok
    @skill = @skill_window.item
    BattleManager.actor.input.set_skill(@skill.id)
    BattleManager.actor.last_skill.object = @skill
    if !@skill.need_selection?
      @skill_window.hide
      next_command
    elsif @skill.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
  end
  #--------------------------------------------------------------------------
  # ● 技能“取消”
  #--------------------------------------------------------------------------
  def on_skill_cancel
    @skill_window.hide
    @actor_command_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 物品“确定”
  #--------------------------------------------------------------------------
  def on_item_ok
    @item = @item_window.item
    BattleManager.actor.input.set_item(@item.id)
    if !@item.need_selection?
      @item_window.hide
      next_command
    elsif @item.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
    $game_party.last_item.object = @item
  end
  #--------------------------------------------------------------------------
  # ● 物品“取消”
  #--------------------------------------------------------------------------
  def on_item_cancel
    @item_window.hide
    @actor_command_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 战斗开始
  #--------------------------------------------------------------------------
  def battle_start
    BattleManager.battle_start
    process_event
    start_party_command_selection
  end
  #--------------------------------------------------------------------------
  # ● 回合开始
  #--------------------------------------------------------------------------
  def turn_start
    @party_command_window.close
    @actor_command_window.close
    @status_window.unselect
    @subject =  nil
    BattleManager.turn_start
    @log_window.wait
    @log_window.clear
  end
  #--------------------------------------------------------------------------
  # ● 回合结束
  #--------------------------------------------------------------------------
  def turn_end
    all_battle_members.each do |battler|
      battler.on_turn_end
      refresh_status
      @log_window.display_auto_affected_status(battler)
      @log_window.wait_and_clear
    end
    BattleManager.turn_end
    process_event
    start_party_command_selection
  end
  #--------------------------------------------------------------------------
  # ● 获取敌我双方的全部参战角色
  #--------------------------------------------------------------------------
  def all_battle_members
    $game_party.members + $game_troop.members
  end
  #--------------------------------------------------------------------------
  # ● 处理事件
  #--------------------------------------------------------------------------
  def process_event
    while !scene_changing?
      $game_troop.interpreter.update
      $game_troop.setup_battle_event
      wait_for_message
      wait_for_effect if $game_troop.all_dead?
      process_forced_action
      BattleManager.judge_win_loss
      break unless $game_troop.interpreter.running?
      update_for_wait
    end
  end
  #--------------------------------------------------------------------------
  # ● 处理强制战斗行动
  #--------------------------------------------------------------------------
  def process_forced_action
    if BattleManager.action_forced?
      last_subject = @subject
      @subject = BattleManager.action_forced_battler
      BattleManager.clear_action_force
      process_action
      @subject = last_subject
    end
  end
  #--------------------------------------------------------------------------
  # ● 处理战斗行动
  #--------------------------------------------------------------------------
  def process_action
    return if scene_changing?
    if !@subject || !@subject.current_action
      @subject = BattleManager.next_subject
    end
    return turn_end unless @subject
    if @subject.current_action
      @subject.current_action.prepare
      if @subject.current_action.valid?
        @status_window.open
        execute_action
      end
      @subject.remove_current_action
    end
    process_action_end unless @subject.current_action
  end
  #--------------------------------------------------------------------------
  # ● 战斗行动结束时的处理
  #--------------------------------------------------------------------------
  def process_action_end
    @subject.on_action_end
    refresh_status
    @log_window.display_auto_affected_status(@subject)
    @log_window.wait_and_clear
    @log_window.display_current_state(@subject)
    @log_window.wait_and_clear
    BattleManager.judge_win_loss
  end
  #--------------------------------------------------------------------------
  # ● 执行战斗行动
  #--------------------------------------------------------------------------
  def execute_action
    @subject.sprite_effect_type = :whiten
    use_item
    @log_window.wait_and_clear
  end
  #--------------------------------------------------------------------------
  # ● 使用技能／物品
  #--------------------------------------------------------------------------
  def use_item
    item = @subject.current_action.item
    @log_window.display_use_item(@subject, item)
    @subject.use_item(item)
    refresh_status
    targets = @subject.current_action.make_targets.compact
    show_animation(targets, item.animation_id)
    targets.each {|target| item.repeats.times { invoke_item(target, item) } }
  end
  #--------------------------------------------------------------------------
  # ● 发动技能／物品
  #--------------------------------------------------------------------------
  def invoke_item(target, item)
    if rand < target.item_cnt(@subject, item)
      invoke_counter_attack(target, item)
    elsif rand < target.item_mrf(@subject, item)
      invoke_magic_reflection(target, item)
    else
      apply_item_effects(apply_substitute(target, item), item)
    end
    @subject.last_target_index = target.index
  end
  #--------------------------------------------------------------------------
  # ● 应用技能／物品效果
  #--------------------------------------------------------------------------
  def apply_item_effects(target, item)
    target.item_apply(@subject, item)
    refresh_status
    @log_window.display_action_results(target, item)
  end
  #--------------------------------------------------------------------------
  # ● 发动反击
  #--------------------------------------------------------------------------
  def invoke_counter_attack(target, item)
    @log_window.display_counter(target, item)
    attack_skill = $data_skills[target.attack_skill_id]
    @subject.item_apply(target, attack_skill)
    refresh_status
    @log_window.display_action_results(@subject, attack_skill)
  end
  #--------------------------------------------------------------------------
  # ● 发动反射魔法攻击
  #--------------------------------------------------------------------------
  def invoke_magic_reflection(target, item)
    @log_window.display_reflection(target, item)
    apply_item_effects(@subject, item)
  end
  #--------------------------------------------------------------------------
  # ● 应用保护弱者
  #--------------------------------------------------------------------------
  def apply_substitute(target, item)
    if check_substitute(target, item)
      substitute = target.friends_unit.substitute_battler
      if substitute && target != substitute
        @log_window.display_substitute(substitute, target)
        return substitute
      end
    end
    target
  end
  #--------------------------------------------------------------------------
  # ● 检查是否能使用保护弱者
  #--------------------------------------------------------------------------
  def check_substitute(target, item)
    target.hp < target.mhp / 4 && (!item || !item.certain?)
  end
  #--------------------------------------------------------------------------
  # ● 显示动画
  #     targets      : 目标的数组
  #     animation_id : 动画 ID（-1: 与普通攻击一样）
  #--------------------------------------------------------------------------
  def show_animation(targets, animation_id)
    if animation_id < 0
      show_attack_animation(targets)
    else
      show_normal_animation(targets, animation_id)
    end
    @log_window.wait
    wait_for_animation
  end
  #--------------------------------------------------------------------------
  # ● 显示攻击动画
  #     targets : 目标的数组
  #    是角色的时候考虑双持武器的效果（反转动画显示左手武器）。
  #    是敌人的时候，在那一瞬间，播放“敌人普通攻击”的声效。
  #--------------------------------------------------------------------------
  def show_attack_animation(targets)
    if @subject.actor?
      show_normal_animation(targets, @subject.atk_animation_id1, false)
      show_normal_animation(targets, @subject.atk_animation_id2, true)
    else
      Sound.play_enemy_attack
      abs_wait_short
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示普通动画
  #     targets      : 目标的数组
  #     animation_id : 动画ID
  #     mirror       : 左右反转
  #--------------------------------------------------------------------------
  def show_normal_animation(targets, animation_id, mirror = false)
    animation = $data_animations[animation_id]
    if animation
      targets.each do |target|
        target.animation_id = animation_id
        target.animation_mirror = mirror
        abs_wait_short unless animation.to_screen?
      end
      abs_wait_short if animation.to_screen?
    end
  end
end
