#encoding:utf-8
#==============================================================================
# ■ Window_BattleLog
#------------------------------------------------------------------------------
# 　用来显示战斗信息的窗口
#   此类窗口没有边框，归类为窗口只是为了方便。
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, window_height)
    self.z = 200
    self.opacity = 0
    @lines = []
    @num_wait = 0
    create_back_bitmap
    create_back_sprite
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_back_bitmap
    dispose_back_sprite
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的宽度
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的高度
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(max_line_number)
  end
  #--------------------------------------------------------------------------
  # ● 获取最大行数
  #--------------------------------------------------------------------------
  def max_line_number
    return 6
  end
  #--------------------------------------------------------------------------
  # ● 生成背景位图
  #--------------------------------------------------------------------------
  def create_back_bitmap
    @back_bitmap = Bitmap.new(width, height)
  end
  #--------------------------------------------------------------------------
  # ● 生成背景精灵
  #--------------------------------------------------------------------------
  def create_back_sprite
    @back_sprite = Sprite.new
    @back_sprite.bitmap = @back_bitmap
    @back_sprite.y = y
    @back_sprite.z = z - 1
  end
  #--------------------------------------------------------------------------
  # ● 释放背景位图
  #--------------------------------------------------------------------------
  def dispose_back_bitmap
    @back_bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # ● 释放背景精灵
  #--------------------------------------------------------------------------
  def dispose_back_sprite
    @back_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    @num_wait = 0
    @lines.clear
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 获取数据行数
  #--------------------------------------------------------------------------
  def line_number
    @lines.size
  end
  #--------------------------------------------------------------------------
  # ● 删除一行文字
  #--------------------------------------------------------------------------
  def back_one
    @lines.pop
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 返回指定行
  #--------------------------------------------------------------------------
  def back_to(line_number)
    @lines.pop while @lines.size > line_number
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 添加文字
  #--------------------------------------------------------------------------
  def add_text(text)
    @lines.push(text)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 替换文字
  #    替换最后一段文字。
  #--------------------------------------------------------------------------
  def replace_text(text)
    @lines.pop
    @lines.push(text)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 获取最下行的文字
  #--------------------------------------------------------------------------
  def last_text
    @lines[-1]
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    draw_background
    contents.clear
    @lines.size.times {|i| draw_line(i) }
  end
  #--------------------------------------------------------------------------
  # ● 绘制背景
  #--------------------------------------------------------------------------
  def draw_background
    @back_bitmap.clear
    @back_bitmap.fill_rect(back_rect, back_color)
  end
  #--------------------------------------------------------------------------
  # ● 获取背景的矩形
  #--------------------------------------------------------------------------
  def back_rect
    Rect.new(0, padding, width, line_number * line_height)
  end
  #--------------------------------------------------------------------------
  # ● 获取背景色
  #--------------------------------------------------------------------------
  def back_color
    Color.new(0, 0, 0, back_opacity)
  end
  #--------------------------------------------------------------------------
  # ● 获取背景的不透明度
  #--------------------------------------------------------------------------
  def back_opacity
    return 64
  end
  #--------------------------------------------------------------------------
  # ● 绘制行
  #--------------------------------------------------------------------------
  def draw_line(line_number)
    rect = item_rect_for_text(line_number)
    contents.clear_rect(rect)
    draw_text_ex(rect.x, rect.y, @lines[line_number])
  end
  #--------------------------------------------------------------------------
  # ● 设置等待用方法
  #--------------------------------------------------------------------------
  def method_wait=(method)
    @method_wait = method
  end
  #--------------------------------------------------------------------------
  # ● 设置效果执行时的等待用方法
  #--------------------------------------------------------------------------
  def method_wait_for_effect=(method)
    @method_wait_for_effect = method
  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def wait
    @num_wait += 1
    @method_wait.call(message_speed) if @method_wait
  end
  #--------------------------------------------------------------------------
  # ● 等待效果执行的结束
  #--------------------------------------------------------------------------
  def wait_for_effect
    @method_wait_for_effect.call if @method_wait_for_effect
  end
  #--------------------------------------------------------------------------
  # ● 获取信息速度
  #--------------------------------------------------------------------------
  def message_speed
    return 20
  end
  #--------------------------------------------------------------------------
  # ● 等待并清除
  #    进行显示信息的最短等待，并在等待结束后清除信息。
  #--------------------------------------------------------------------------
  def wait_and_clear
    wait while @num_wait < 2 if line_number > 0
    clear
  end
  #--------------------------------------------------------------------------
  # ● 显示当前状态
  #--------------------------------------------------------------------------
  def display_current_state(subject)
    unless subject.most_important_state_text.empty?
      add_text(subject.name + subject.most_important_state_text)
      wait
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示使用技能／物品
  #--------------------------------------------------------------------------
  def display_use_item(subject, item)
    if item.is_a?(RPG::Skill)
      add_text(subject.name + item.message1)
      unless item.message2.empty?
        wait
        add_text(item.message2)
      end
    else
      add_text(sprintf(Vocab::UseItem, subject.name, item.name))
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示反击
  #--------------------------------------------------------------------------
  def display_counter(target, item)
    Sound.play_evasion
    add_text(sprintf(Vocab::CounterAttack, target.name))
    wait
    back_one
  end
  #--------------------------------------------------------------------------
  # ● 显示反射
  #--------------------------------------------------------------------------
  def display_reflection(target, item)
    Sound.play_reflection
    add_text(sprintf(Vocab::MagicReflection, target.name))
    wait
    back_one
  end
  #--------------------------------------------------------------------------
  # ● 显示保护弱者
  #--------------------------------------------------------------------------
  def display_substitute(substitute, target)
    add_text(sprintf(Vocab::Substitute, substitute.name, target.name))
    wait
    back_one
  end
  #--------------------------------------------------------------------------
  # ● 显示行动结果
  #--------------------------------------------------------------------------
  def display_action_results(target, item)
    if target.result.used
      last_line_number = line_number
      display_critical(target, item)
      display_damage(target, item)
      display_affected_status(target, item)
      display_failure(target, item)
      wait if line_number > last_line_number
      back_to(last_line_number)
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示失败
  #--------------------------------------------------------------------------
  def display_failure(target, item)
    if target.result.hit? && !target.result.success
      add_text(sprintf(Vocab::ActionFailure, target.name))
      wait
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示关键一击
  #--------------------------------------------------------------------------
  def display_critical(target, item)
    if target.result.critical
      text = target.actor? ? Vocab::CriticalToActor : Vocab::CriticalToEnemy
      add_text(text)
      wait
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示伤害
  #--------------------------------------------------------------------------
  def display_damage(target, item)
    if target.result.missed
      display_miss(target, item)
    elsif target.result.evaded
      display_evasion(target, item)
    else
      display_hp_damage(target, item)
      display_mp_damage(target, item)
      display_tp_damage(target, item)
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示落空
  #--------------------------------------------------------------------------
  def display_miss(target, item)
    if !item || item.physical?
      fmt = target.actor? ? Vocab::ActorNoHit : Vocab::EnemyNoHit
      Sound.play_miss
    else
      fmt = Vocab::ActionFailure
    end
    add_text(sprintf(fmt, target.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ● 显示闪避
  #--------------------------------------------------------------------------
  def display_evasion(target, item)
    if !item || item.physical?
      fmt = Vocab::Evasion
      Sound.play_evasion
    else
      fmt = Vocab::MagicEvasion
      Sound.play_magic_evasion
    end
    add_text(sprintf(fmt, target.name))
    wait
  end
  #--------------------------------------------------------------------------
  # ● 显示 HP 伤害
  #--------------------------------------------------------------------------
  def display_hp_damage(target, item)
    return if target.result.hp_damage == 0 && item && !item.damage.to_hp?
    if target.result.hp_damage > 0 && target.result.hp_drain == 0
      target.perform_damage_effect
    end
    Sound.play_recovery if target.result.hp_damage < 0
    add_text(target.result.hp_damage_text)
    wait
  end
  #--------------------------------------------------------------------------
  # ● 显示 MP 伤害
  #--------------------------------------------------------------------------
  def display_mp_damage(target, item)
    return if target.dead? || target.result.mp_damage == 0
    Sound.play_recovery if target.result.mp_damage < 0
    add_text(target.result.mp_damage_text)
    wait
  end
  #--------------------------------------------------------------------------
  # ● 显示 TP 伤害
  #--------------------------------------------------------------------------
  def display_tp_damage(target, item)
    return if target.dead? || target.result.tp_damage == 0
    Sound.play_recovery if target.result.tp_damage < 0
    add_text(target.result.tp_damage_text)
    wait
  end
  #--------------------------------------------------------------------------
  # ● 显示普通状态的效果影响
  #--------------------------------------------------------------------------
  def display_affected_status(target, item)
    if target.result.status_affected?
      add_text("") if line_number < max_line_number
      display_changed_states(target)
      display_changed_buffs(target)
      back_one if last_text.empty?
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示自动状态的效果影响
  #--------------------------------------------------------------------------
  def display_auto_affected_status(target)
    if target.result.status_affected?
      display_affected_status(target, nil)
      wait if line_number > 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示状态附加／解除
  #--------------------------------------------------------------------------
  def display_changed_states(target)
    display_added_states(target)
    display_removed_states(target)
  end
  #--------------------------------------------------------------------------
  # ● 显示状态附加
  #--------------------------------------------------------------------------
  def display_added_states(target)
    target.result.added_state_objects.each do |state|
      state_msg = target.actor? ? state.message1 : state.message2
      target.perform_collapse_effect if state.id == target.death_state_id
      next if state_msg.empty?
      replace_text(target.name + state_msg)
      wait
      wait_for_effect
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示状态解除
  #--------------------------------------------------------------------------
  def display_removed_states(target)
    target.result.removed_state_objects.each do |state|
      next if state.message4.empty?
      replace_text(target.name + state.message4)
      wait
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示能力强化／弱化
  #--------------------------------------------------------------------------
  def display_changed_buffs(target)
    display_buffs(target, target.result.added_buffs, Vocab::BuffAdd)
    display_buffs(target, target.result.added_debuffs, Vocab::DebuffAdd)
    display_buffs(target, target.result.removed_buffs, Vocab::BuffRemove)
  end
  #--------------------------------------------------------------------------
  # ● 显示能力强化／弱化（个別）
  #--------------------------------------------------------------------------
  def display_buffs(target, buffs, fmt)
    buffs.each do |param_id|
      replace_text(sprintf(fmt, target.name, Vocab::param(param_id)))
      wait
    end
  end
end
