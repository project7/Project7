#encoding:utf-8
#==============================================================================
# ■ Sprite_Battler
#------------------------------------------------------------------------------
# 　显示战斗者的精灵。根据 Game_Battler 类的实例自动变化。
#==============================================================================

class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :battler
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(viewport, battler = nil)
    super(viewport)
    @battler = battler
    @battler_visible = false
    @effect_type = nil
    @effect_duration = 0
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    bitmap.dispose if bitmap
    super
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    if @battler
      @use_sprite = @battler.use_sprite?
      if @use_sprite
        update_bitmap
        update_origin
        update_position
      end
      setup_new_effect
      setup_new_animation
      update_effect
    else
      self.bitmap = nil
      @effect_type = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新源位图（Source Bitmap）
  #--------------------------------------------------------------------------
  def update_bitmap
    new_bitmap = Cache.battler(@battler.battler_name, @battler.battler_hue)
    if bitmap != new_bitmap
      self.bitmap = new_bitmap
      init_visibility
    end
  end
  #--------------------------------------------------------------------------
  # ● 初始化可视状态
  #--------------------------------------------------------------------------
  def init_visibility
    @battler_visible = @battler.alive?
    self.opacity = 0 unless @battler_visible
  end
  #--------------------------------------------------------------------------
  # ● 更新原点
  #--------------------------------------------------------------------------
  def update_origin
    if bitmap
      self.ox = bitmap.width / 2
      self.oy = bitmap.height
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新位置
  #--------------------------------------------------------------------------
  def update_position
    self.x = @battler.screen_x
    self.y = @battler.screen_y
    self.z = @battler.screen_z
  end
  #--------------------------------------------------------------------------
  # ● 设置新的效果
  #--------------------------------------------------------------------------
  def setup_new_effect
    if !@battler_visible && @battler.alive?
      start_effect(:appear)
    elsif @battler_visible && @battler.hidden?
      start_effect(:disappear)
    end
    if @battler_visible && @battler.sprite_effect_type
      start_effect(@battler.sprite_effect_type)
      @battler.sprite_effect_type = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 效果开始
  #--------------------------------------------------------------------------
  def start_effect(effect_type)
    @effect_type = effect_type
    case @effect_type
    when :appear
      @effect_duration = 16
      @battler_visible = true
    when :disappear
      @effect_duration = 32
      @battler_visible = false
    when :whiten
      @effect_duration = 16
      @battler_visible = true
    when :blink
      @effect_duration = 20
      @battler_visible = true
    when :collapse
      @effect_duration = 48
      @battler_visible = false
    when :boss_collapse
      @effect_duration = bitmap.height
      @battler_visible = false
    when :instant_collapse
      @effect_duration = 16
      @battler_visible = false
    end
    revert_to_normal
  end
  #--------------------------------------------------------------------------
  # ● 返回普通设置
  #--------------------------------------------------------------------------
  def revert_to_normal
    self.blend_type = 0
    self.color.set(0, 0, 0, 0)
    self.opacity = 255
    self.ox = bitmap.width / 2 if bitmap
    self.src_rect.y = 0
  end
  #--------------------------------------------------------------------------
  # ● 设置新的动画
  #--------------------------------------------------------------------------
  def setup_new_animation
    if @battler.animation_id > 0
      animation = $data_animations[@battler.animation_id]
      mirror = @battler.animation_mirror
      start_animation(animation, mirror)
      @battler.animation_id = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定效果是否执行中
  #--------------------------------------------------------------------------
  def effect?
    @effect_type != nil
  end
  #--------------------------------------------------------------------------
  # ● 更新效果
  #--------------------------------------------------------------------------
  def update_effect
    if @effect_duration > 0
      @effect_duration -= 1
      case @effect_type
      when :whiten
        update_whiten
      when :blink
        update_blink
      when :appear
        update_appear
      when :disappear
        update_disappear
      when :collapse
        update_collapse
      when :boss_collapse
        update_boss_collapse
      when :instant_collapse
        update_instant_collapse
      end
      @effect_type = nil if @effect_duration == 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新白闪烁效果
  #--------------------------------------------------------------------------
  def update_whiten
    self.color.set(255, 255, 255, 0)
    self.color.alpha = 128 - (16 - @effect_duration) * 10
  end
  #--------------------------------------------------------------------------
  # ● 更新明灭效果
  #--------------------------------------------------------------------------
  def update_blink
    self.opacity = (@effect_duration % 10 < 5) ? 255 : 0
  end
  #--------------------------------------------------------------------------
  # ● 更新出现效果
  #--------------------------------------------------------------------------
  def update_appear
    self.opacity = (16 - @effect_duration) * 16
  end
  #--------------------------------------------------------------------------
  # ● 更新消灭效果
  #--------------------------------------------------------------------------
  def update_disappear
    self.opacity = 256 - (32 - @effect_duration) * 10
  end
  #--------------------------------------------------------------------------
  # ● 更新击溃效果
  #--------------------------------------------------------------------------
  def update_collapse
    self.blend_type = 1
    self.color.set(255, 128, 128, 128)
    self.opacity = 256 - (48 - @effect_duration) * 6
  end
  #--------------------------------------------------------------------------
  # ● 更新击溃首领效果
  #--------------------------------------------------------------------------
  def update_boss_collapse
    alpha = @effect_duration * 120 / bitmap.height
    self.ox = bitmap.width / 2 + @effect_duration % 2 * 4 - 2
    self.blend_type = 1
    self.color.set(255, 255, 255, 255 - alpha)
    self.opacity = alpha
    self.src_rect.y -= 1
    Sound.play_boss_collapse2 if @effect_duration % 20 == 19
  end
  #--------------------------------------------------------------------------
  # ● 更新瞬间消失效果
  #--------------------------------------------------------------------------
  def update_instant_collapse
    self.opacity = 0
  end
end
