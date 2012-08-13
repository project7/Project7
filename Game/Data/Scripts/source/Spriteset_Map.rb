#encoding:utf-8
#==============================================================================
# ■ Spriteset_Map
#------------------------------------------------------------------------------
# 　处理地图画面精灵和图块的类。本类在 Scene_Map 类的内部使用。
#==============================================================================

class Spriteset_Map
  
  attr_accessor :fillup
  attr_accessor :tips
  attr_accessor :tipsvar
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    create_viewports
    create_tilemap
    create_parallax
    create_ui_view
    create_characters
    create_shadow
    create_weather
    create_pictures
    create_timer
    update
  end
  #--------------------------------------------------------------------------
  # ● 生成显示端口
  #--------------------------------------------------------------------------
  def create_viewports
    @viewport1 = Viewport.new
    @viewport2 = Viewport.new
    @viewport3 = Viewport.new
    @viewport2.z = 50
    @viewport3.z = 100
  end
  #--------------------------------------------------------------------------
  # ● 读取图块地图
  #--------------------------------------------------------------------------
  def create_tilemap
    @tilemap = Tilemap.new(@viewport1)
    @tilemap.map_data = $game_map.data
    load_tileset
  end
  #--------------------------------------------------------------------------
  # ● 读取图块组
  #--------------------------------------------------------------------------
  def load_tileset
    @tileset = $game_map.tileset
    @tileset.tileset_names.each_with_index do |name, i|
      @tilemap.bitmaps[i] = Cache.tileset(name)
    end
    @tilemap.flags = @tileset.flags
  end
  #--------------------------------------------------------------------------
  # ● 生成远景图
  #--------------------------------------------------------------------------
  def create_parallax
    @parallax = Plane.new(@viewport1)
    @parallax.z = -100
  end
  #--------------------------------------------------------------------------
  # ● 生成战旗UI
  #--------------------------------------------------------------------------
  def create_ui_view
    # 地板
    @fillup = 
    [ Sprite.new(@viewport1),
      Sprite.new(@viewport1),
      Sprite.new(@viewport1),
      Sprite.new(@viewport1),
      Sprite.new(@viewport1)
    ]
    @fillup.each_with_index{|i,j| i.opacity = Fuc::SP_OPA[j]}
    @fillup[0].bitmap = Fuc.mouse_icon
    @fillup[0].z = 5
    @fillup[1].z = 1
    @fillup[2].z = 2
    @fillup[3].z = 4
    @fillup[4].z = 3
    # UI
    @tipsvar = [[0,0],[true,10],[false,0],nil,nil,nil,0,nil,nil,[],[false,-1],[],[],[],[],[false,-1],[],[false,0],[false,-1],false,-1]
    @tips = 
    [ Sprite.new(@viewport2),
      Sprite.new(@viewport3),
      Sprite.new(@viewport3),
      Sprite.new(@viewport3),
      Sprite.new(@viewport3),
      Sprite.new(@viewport3),
      Sprite.new(@viewport3),
      Sprite.new(@viewport3),
      Sprite.new(@viewport3),
      Sprite.new(@viewport3),
      Sprite.new(@viewport3),
      Sprite.new(@viewport3),
      Sprite.new(@viewport3),
      Sprite.new(@viewport3),
      Sprite.new(@viewport3),
      Sprite.new(@viewport3),
      Sprite.new(@viewport3)
    ]
    @tips[0].z = 1                                      #鼠标指针
    @tips[1].bitmap = Fuc.ui_item                       #物品栏
    @tips[1].x = -175
    @tips[1].y = Graphics.height*77/100
    @tips[1].z = 100
    @tips[2].bitmap = Fuc.ui_item_rect                  #物品栏选框
    @tips[2].y = @tips[1].y+12
    @tips[2].z = 102
    @tips[3].bitmap = Fuc.ui_detail                     #头像背景
    @tips[3].y = 6
    @tips[3].x = 6
    @tips[3].z = 100
    @tips[4].y = 6                                      #头像
    @tips[4].x = 6
    @tips[4].z = 101
    @tips[5].y = 6                                      #头像资料ap
    @tips[5].x = 6
    @tips[5].z = 102
    @tips[6].bitmap = Bitmap.new(Fuc::TIPS_TEXT)        #提示文字背景
    @tips[6].y = Graphics.height - @tips[6].bitmap.height-10
    @tips[6].x = Graphics.width/2-@tips[6].bitmap.width/2
    @tips[6].opacity = 0
    @tips[6].z = 102
    @tips[7].bitmap = Bitmap.new(@tips[6].bitmap.width*2,@tips[6].bitmap.height)
    #@tips[7].bitmap.font.color = Fuc::TIPS_TEXT_COLOR
    @tips[7].bitmap.font.shadow = false
    @tips[7].y = Graphics.height - @tips[7].bitmap.height-10  #提示文字
    @tips[7].x = Graphics.width/2-@tips[7].bitmap.width/2
    @tips[7].opacity = 0
    @tips[7].z = 103
    @tips[8].bitmap = Bitmap.new(Fuc::BUFF_BACK)        #buff背景
    @tips[8].x = Graphics.width-@tips[8].bitmap.width
    @tips[8].z = 100
    @tips[9].bitmap = Fuc.get_buff_bitmap;@tipsvar[9]=$sel_body ? $sel_body.buff_rem : []      #buff图标
    @tips[9].y = @tips[8].y+@tips[8].bitmap.height/2-@tips[9].bitmap.height/2
    @tips[9].x = Graphics.width-@tips[9].bitmap.width
    @tips[9].z = 101
    @tips[10].y = @tips[8].y+@tips[8].bitmap.height
    @tips[10].z = 102         #提示
    [*11..14].each do |i|                   # 道具显示
      @tips[i].bitmap = Fuc.get_item_bitmap(i-11)
      @tips[i].y = @tips[1].y+12
      @tips[i].x = @tips[1].x+5+(i-11)*41
      @tips[i].z = 101
    end
    @tips[15].bitmap = Bitmap.new(Fuc::SKILL_BACK)                                #技能背景
    @tips[15].y = Graphics.height-5-@tips[15].bitmap.height
    @tips[15].x = Graphics.width-5-@tips[15].bitmap.width
    @tips[15].z = 100
    @tips[16].bitmap = Fuc.get_all_skill_bitmap                                   #技能
    @tips[16].y = @tips[15].y
    @tips[16].x = @tips[15].x
    @tips[16].z = 101
    # 数据显示
    @richtext = []
    @richvalue = {}
  end
  #--------------------------------------------------------------------------
  # ● 自动适应屏幕
  #--------------------------------------------------------------------------
  def adapt_screen
    @viewport1.rect.width = Graphics.width
    @viewport1.rect.height = Graphics.height
    @viewport2.rect.width = Graphics.width
    @viewport2.rect.height = Graphics.height
    @viewport3.rect.width = Graphics.width
    @viewport3.rect.height = Graphics.height
    @tips[1].y = Graphics.height*77/100
    @tips[2].y = @tips[1].y+12
    @tips[6].y = Graphics.height - @tips[6].bitmap.height-10
    @tips[6].x = Graphics.width/2-@tips[6].bitmap.width/2
    @tips[7].y = Graphics.height - @tips[7].bitmap.height-10  #提示文字
    @tips[7].x = Graphics.width/2-@tips[7].bitmap.width/2
    @tips[8].x = Graphics.width-@tips[8].bitmap.width
    @tips[9].y = @tips[8].y+@tips[8].bitmap.height/2-@tips[9].bitmap.height/2
    @tips[9].x = Graphics.width-@tips[9].bitmap.width
    [*11..14].each do |i|                   # 道具显示
      @tips[i].y = @tips[1].y+12
      @tips[i].x = @tips[1].x+5+(i-11)*41
    end
    @tips[15].y = Graphics.height-5-@tips[15].bitmap.height
    @tips[15].x = Graphics.width-5-@tips[15].bitmap.width
    @tips[16].y = @tips[15].y
    @tips[16].x = @tips[15].x
  end
  #--------------------------------------------------------------------------
  # ● 增加数据显示
  #--------------------------------------------------------------------------
  def show_text(text,xy,color=Fuc::WHITE_COLOR,size=20)
    @richtext << Sprite_RichText.new(text,xy,color,size,@viewport3)
  end
  #--------------------------------------------------------------------------
  # ● 增加血条显示
  #--------------------------------------------------------------------------
  def show_value(rate,xy,color=Fuc::HP_VALUE_COLOR,wh=nil)
    if @richvalue[xy]
      @richvalue[xy].refresh(rate,xy,color,wh)
    else
      @richvalue[xy] = Sprite_RichValue.new(rate,xy,color,wh,@viewport3)
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示提示文字
  #--------------------------------------------------------------------------
  def show_tips(text)
    @tips[7].bitmap.clear
    @tips[7].bitmap.draw_text(0,0,@tips[7].bitmap.width,@tips[7].bitmap.height,text,1)
    @tips[6].opacity = @tips[7].opacity = 255
    @tipsvar[6] = 60
  end
  #--------------------------------------------------------------------------
  # ● 生成人物精灵
  #--------------------------------------------------------------------------
  def create_characters
    @character_sprites = []
    $game_map.events.values.each do |event|
      @character_sprites.push(Sprite_Character.new(@viewport1, event))
    end
    $game_map.vehicles.each do |vehicle|
      @character_sprites.push(Sprite_Character.new(@viewport1, vehicle))
    end
    $game_player.followers.reverse_each do |follower|
      @character_sprites.push(Sprite_Character.new(@viewport1, follower))
    end
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
    @map_id = $game_map.map_id
  end
  
  #--------------------------------------------------------------------------
  # ● 生成飞艇影子
  #--------------------------------------------------------------------------
  def create_shadow
    @shadow_sprite = Sprite.new(@viewport1)
    @shadow_sprite.bitmap = Cache.system("Shadow")
    @shadow_sprite.ox = @shadow_sprite.bitmap.width / 2
    @shadow_sprite.oy = @shadow_sprite.bitmap.height
    @shadow_sprite.z = 180
  end
  #--------------------------------------------------------------------------
  # ● 生成天气
  #--------------------------------------------------------------------------
  def create_weather
    @weather = Spriteset_Weather.new(@viewport2)
  end
  #--------------------------------------------------------------------------
  # ● 生成图片精灵
  #--------------------------------------------------------------------------
  def create_pictures
    @picture_sprites = []
  end
  #--------------------------------------------------------------------------
  # ● 生成计时器精灵
  #--------------------------------------------------------------------------
  def create_timer
    @timer_sprite = Sprite_Timer.new(@viewport2)
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    dispose_tilemap
    dispose_parallax
    dispose_characters
    dispose_shadow
    dispose_weather
    dispose_ui_view
    dispose_pictures
    dispose_timer
    dispose_viewports
  end
  #--------------------------------------------------------------------------
  # ● 释放地图图块
  #--------------------------------------------------------------------------
  def dispose_tilemap
    @tilemap.dispose
  end
  #--------------------------------------------------------------------------
  # ● 释放远景图
  #--------------------------------------------------------------------------
  def dispose_parallax
    @parallax.bitmap.dispose if @parallax.bitmap
    @parallax.dispose
  end
  #--------------------------------------------------------------------------
  # ● 释放人物精灵
  #--------------------------------------------------------------------------
  def dispose_characters
    @character_sprites.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # ● 释放飞艇影子
  #--------------------------------------------------------------------------
  def dispose_shadow
    @shadow_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 释放天气
  #--------------------------------------------------------------------------
  def dispose_weather
    @weather.dispose
  end
  #--------------------------------------------------------------------------
  # ● 释放图片精灵
  #--------------------------------------------------------------------------
  def dispose_pictures
    @picture_sprites.compact.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # ● 释放计时器精灵
  #--------------------------------------------------------------------------
  def dispose_timer
    @timer_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 释放显示端口
  #--------------------------------------------------------------------------
  def dispose_viewports
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  #--------------------------------------------------------------------------
  # ● 释放战旗界面
  #--------------------------------------------------------------------------
  def dispose_ui_view
    @fillup.each{|i| i.bitmap.dispose if i.bitmap;i.dispose}
    @tips.each{|i| i.bitmap.dispose if i.bitmap;i.dispose}
    @richtext.each{|i| i.bitmap.dispose if i.bitmap;i.dispose}
    @richvalue.each_value{|i| i.bitmap.dispose if i.bitmap;i.dispose}
  end
  #--------------------------------------------------------------------------
  # ● 更新人物
  #--------------------------------------------------------------------------
  def refresh_characters
    dispose_characters
    create_characters
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    update_tileset
    update_tilemap
    update_parallax
    update_characters
    update_ui_view
    update_shadow
    update_weather
    update_pictures
    update_timer
    update_viewports
  end
  #--------------------------------------------------------------------------
  # ● 监视图块组是否需要被切换
  #--------------------------------------------------------------------------
  def update_tileset
    if @tileset != $game_map.tileset
      load_tileset
      refresh_characters
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新地图图块
  #--------------------------------------------------------------------------
  def update_tilemap
    @tilemap.map_data = $game_map.data
    @tilemap.ox = $game_map.display_x * 32
    @tilemap.oy = $game_map.display_y * 32
    @tilemap.update
  end
  #--------------------------------------------------------------------------
  # ● 更新远景图
  #--------------------------------------------------------------------------
  def update_parallax
    if @parallax_name != $game_map.parallax_name
      @parallax_name = $game_map.parallax_name
      @parallax.bitmap.dispose if @parallax.bitmap
      @parallax.bitmap = Cache.parallax(@parallax_name) if @parallax_name.size > 0
      Graphics.frame_reset
    end
    newox = $game_map.parallax_ox(@parallax.bitmap)
    newoy = $game_map.parallax_oy(@parallax.bitmap)
    @parallax.ox = @parallaxlastox = newox unless @parallaxlastox == newox
    @parallax.oy = @parallaxlastoy = newoy unless @parallaxlastoy == newoy
  end
  #--------------------------------------------------------------------------
  # ● 更新人物精灵
  #--------------------------------------------------------------------------
  def update_characters
    refresh_characters if @map_id != $game_map.map_id
    @character_sprites.each {|sprite| sprite.update }
  end
  #--------------------------------------------------------------------------
  # ● 更新战旗界面
  #--------------------------------------------------------------------------
  def update_ui_view
    # 刷地板
    [*0...@fillup.size].each do |i|
      case i
      when 0
        if $map_battle && $map_battle.scene_id == 0 && !$map_battle.mouse_right_down && !$game_message.busy? && !$game_message.visible
          tpos = Fuc.getpos_by_screenpos(Mouse.pos)
          @fillup[0].x = $game_map.adjust_x(tpos[0]) * 32
          @fillup[0].y = $game_map.adjust_y(tpos[1]) * 32
          @fillup[0].visible = true
        else
          @fillup[0].visible = false
        end
      when 1
        break unless $map_battle
        if $map_battle.movearea
          @fillup[1].x = $map_battle.movearea.screen_x
          @fillup[1].y = $map_battle.movearea.screen_y
        end
      when 2
        break unless $map_battle
        if $map_battle.wayarea
          @fillup[2].x = $map_battle.wayarea.screen_x
          @fillup[2].y = $map_battle.wayarea.screen_y
        end
      when 3
        break unless $map_battle
        if $map_battle.effectarea
          tpos = Fuc.getpos_by_screenpos(Mouse.pos)
          $map_battle.effectarea.x = tpos[0] unless $map_battle.cur_actor.ai
          $map_battle.effectarea.y = tpos[1] unless $map_battle.cur_actor.ai
          @fillup[3].x = $map_battle.effectarea.screen_x
          @fillup[3].y = $map_battle.effectarea.screen_y
        end
      when 4
        break unless $map_battle
        if $map_battle.enablearea
          @fillup[4].x = $map_battle.enablearea.screen_x
          @fillup[4].y = $map_battle.enablearea.screen_y
        end
      end
    end
    # 刷UI
    [*0...@tips.size].each do |i|
      case i
      when 0
        next unless $map_battle
        if @tips[0].bitmap
          if @tipsvar[0][0] > 6
            @tipsvar[0][0] = 0
            if @tipsvar[0][1] >= 3
              @tipsvar[0][1] = 0
            else
              @tipsvar[0][1]+=1
            end
          else
            @tipsvar[0][0]+=1
          end
          sw = @tips[0].bitmap.width/4
          sh = @tips[0].bitmap.height
          sx = @tipsvar[0][1]*sw
          sy = 0
          @tips[0].src_rect.set(sx, sy, sw, sh)
          @tips[0].x = $map_battle.cur_actor.event.screen_x
          @tips[0].y = $map_battle.cur_actor.event.screen_y-$map_battle.cur_actor.event.gra_height
          @tips[0].ox = sw / 2
          @tips[0].oy = sh
        end
      when 1
        if @tipsvar[1][0]
          if @tips[1].x-@tipsvar[1][1] <= -175
            @tips[1].x = -175
          else
            @tips[1].x -= @tipsvar[1][1]
          end
        else
          if @tips[1].x+@tipsvar[1][1] >= 0
            @tips[1].x = 0
          else
            @tips[1].x += @tipsvar[1][1]
          end
        end
      when 2
        @tips[2].visible = @tipsvar[2][0]
        @tips[2].x = @tips[1].x+5+@tipsvar[2][1]*41 if @tipsvar[2][0]
      when 4
        unless $map_battle
          $sel_body = $party.members[0]
        end
        if $sel_body != @last_sel_body1
          @tips[4].bitmap.dispose if @tips[4].bitmap
          @tips[4].bitmap = Fuc.ui_head
          @tips[4].y = @tips[3].y+@tips[3].bitmap.height-@tips[4].bitmap.height-4 if @tips[4].bitmap
          @last_sel_body1 = $sel_body
        end
      when 5
        unless $sel_body
          @tips[5].bitmap.dispose if @tips[5].bitmap
          next
        end
        if $sel_body.ap != @last_value1 || $sel_body.name != @last_value2 || $sel_body != @last_sel_body2
          @tips[5].bitmap.dispose if @tips[5].bitmap
          @tips[5].bitmap = Fuc.ui_head_detail
          @last_value1 = $sel_body.ap
          @last_value2 = $sel_body.name
          @last_sel_body2 = $sel_body
        end
      when 6
        if @tipsvar[6] <= 0
          @tipsvar[6] = 0
          @tips[6].opacity >= 5 ? @tips[6].opacity-=5 : @tips[6].opacity = 0
        else
          @tipsvar[6] -= 1
        end
      when 7
        @tips[7].opacity = @tips[6].opacity
      when 9
        @tips[9].bitmap.dispose if !$sel_body && @tips[9].bitmap
        if @tipsvar[9]!=$sel_body.buff_rem
          @tips[9].bitmap.dispose if @tips[9].bitmap
          @tips[9].bitmap = Fuc.get_buff_bitmap
          @tips[9].x = Graphics.width-@tips[9].bitmap.width
          @tipsvar[9]=$sel_body.buff_rem.clone
        end
      when 10
        if $game_message.busy? || $game_message.visible
          @tips[10].bitmap.dispose if @tips[10].bitmap
          next
        end
        dx = Mouse.pos[0]-@tips[9].x
        dy = Mouse.pos[1]-@tips[9].y
        if $sel_body.buff!=[]&&dx>=0&&dx<=@tips[9].bitmap.width&&dy>=0&&dy<=@tips[9].bitmap.height
          if !@tipsvar[10][0] || @tipsvar[10][1]!=dx/22
            @tipsvar[10][0] = true
            @tipsvar[10][1] = dx/22
            @tips[10].bitmap = Fuc.get_buff_descr(dx/22)
            @tips[10].x = Graphics.width-@tips[10].bitmap.width-4
            @tips[10].y = @tips[8].y+@tips[8].bitmap.height
          end
        elsif !@tipsvar[1][0] && @tipsvar[2][0] && $sel_body.bag[@tipsvar[2][1]]
          if !@tipsvar[15][0] || @tipsvar[15][1]!=@tipsvar[2][1]
            @tipsvar[15][0] = true
            @tipsvar[15][1] = @tipsvar[2][1]
            @tips[10].bitmap = Fuc.get_item_descr(@tipsvar[2][1])
            @tips[10].x = 4
            @tips[10].y = @tips[1].y-@tips[10].bitmap.height
          end
        elsif @tipsvar[19] && @tipsvar[17][0] && $sel_body.skill[@tipsvar[17][1]]
          if !@tipsvar[18][0] || @tipsvar[18][1]!=@tipsvar[17][1] || @tipsvar[16]!=$sel_body.skill_rem
            @tipsvar[18][0] = true
            @tipsvar[18][1] = @tipsvar[17][1]
            @tips[10].bitmap = Fuc.get_skill_descr(@tipsvar[17][1])
            @tips[10].x = Graphics.width-4-@tips[10].bitmap.width
            @tips[10].y = @tips[16].y-@tips[10].bitmap.height-4
          end
        else
          if @tipsvar[10][0] || @tipsvar[15][0] || @tipsvar[18][0]
            @tipsvar[10][0] = false
            @tipsvar[10][1] = -1
            @tipsvar[15][0] = false
            @tipsvar[15][1] = -1
            @tipsvar[18][0] = false
            @tipsvar[18][1] = -1
          end
          @tips[10].bitmap.dispose if @tips[10].bitmap
        end
      when 11..14
        next unless $sel_body.bag_rem[i-11]
        if @tipsvar[i]!=$sel_body.bag_rem[i-11]
          @tipsvar[i]=$sel_body.bag_rem[i-11].clone
          @tips[i].bitmap.dispose if @tips[i].bitmap
          @tips[i].bitmap = Fuc.get_item_bitmap(i-11)
        end
        @tips[i].y = @tips[1].y+12
        @tips[i].x = @tips[1].x+5+(i-11)*41
      when 16
        if @tipsvar[16]!=$sel_body.skill_rem || @tipsvar[20]!=$sel_body.sp
          @menu_calling = false
          @tipsvar[16]=$sel_body.skill_rem.clone
          @tipsvar[20]=$sel_body.sp
          @tips[16].bitmap.dispose if @tips[16].bitmap
          @tips[16].bitmap = Fuc.get_all_skill_bitmap
        end
      end
    end
    # 刷数据
    @richtext.each_with_index do |i,j|
      unless i.bitmap
        @richtext[j] = nil
        next
      end
      if i.dead
        i.dispose
        @richtext[j] = nil
      else
        i.update
      end
    end
    @richtext.compact!
    @richvalue.each_key do |i|
      unless @richvalue[i].bitmap
        @richvalue[i] = nil
        next
      end
      if @richvalue[i].dead
        @richvalue[i].dispose
        @richvalue[i] = nil
      else
        @richvalue[i].update
      end
    end
    @richvalue.delete_if{|key| !@richvalue[key]}
  end
  #--------------------------------------------------------------------------
  # ● 更新飞艇影子
  #--------------------------------------------------------------------------
  def update_shadow
    airship = $game_map.airship
    @shadow_sprite.x = airship.screen_x
    @shadow_sprite.y = airship.screen_y + airship.altitude
    @shadow_sprite.opacity = airship.altitude * 8
    @shadow_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 更新天气
  #--------------------------------------------------------------------------
  def update_weather
    @weather.type = $game_map.screen.weather_type
    @weather.power = $game_map.screen.weather_power
    @weather.ox = $game_map.display_x * 32
    @weather.oy = $game_map.display_y * 32
    @weather.update
  end
  #--------------------------------------------------------------------------
  # ● 更新图片精灵
  #--------------------------------------------------------------------------
  def update_pictures
    $game_map.screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport2, pic)
      @picture_sprites[pic.number].update
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新计时器精灵
  #--------------------------------------------------------------------------
  def update_timer
    @timer_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 更新显示端口
  #--------------------------------------------------------------------------
  def update_viewports
    @viewport1.tone.set($game_map.screen.tone)
    @viewport1.ox = $game_map.screen.shake
    @viewport2.color.set($game_map.screen.flash_color)
    @viewport3.color.set(0, 0, 0, 255 - $game_map.screen.brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end
end
