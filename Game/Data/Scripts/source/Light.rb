#-------------------------------------------------------------------------------
# * [ACE] Khas Awesome Light Effects
#-------------------------------------------------------------------------------
# * By Khas Arcthunder - arcthunder.site40.net
# * Version: 1.0 EN
# * Released on: 17/01/2012
#
#-------------------------------------------------------------------------------
# * Terms of Use
#-------------------------------------------------------------------------------
# When using any Khas script, you agree with the following terms:
# 1. You must give credit to Khas;
# 2. All Khas scripts are licensed under a Creative Commons license;
# 3. All Khas scripts are for non-commercial projects. If you need some script 
#    for your commercial project (I accept requests for this type of project), 
#    send an email to nilokruch@live.com with your request;
# 4. All Khas scripts are for personal use, you can use or edit for your own 
#    project, but you are not allowed to post any modified version;
# 5. You can’t give credit to yourself for posting any Khas script;
# 6. If you want to share a Khas script, don’t post the direct download link, 
#    please redirect the user to arcthunder.site40.net
#
#-------------------------------------------------------------------------------
# * Features
#-------------------------------------------------------------------------------
# - Realistic Light
# - Light does not pass over walls, blocks and roofs
# - Static Light Sources
# - Dynamic Light Sources (like a player's lantern)
# - Multiple effects
# - Easy to use (comments)
#
#-------------------------------------------------------------------------------
# * WARNING - Performance
#-------------------------------------------------------------------------------
# This script may be too heavy to old processors! The Awesome Light Effects was
# tested on a Core 2 Duo E4500 and on a Core i5, without any lag. However,
# there's other factors that may influence the script performance:
#
# 1. Map size
# This script searches surfaces on the map, in order to cut the light pictures.
# In a huge map, the number of surfaces may increase a lot, affecting the
# DYNAMIC LIGHT SOURCE only. Map size does not influence the static sources.
#
# 2. Number of effects
# This script draws the effects on the screen, but before drawing, it checks 
# if the effect is out of screen (in this case, the script will skip the 
# light drawing). Too much effects may cause lag, but this is just a prevision.
#
# 3. Effect's picture size
# The picture size of the DYNAMIC LIGHT SOURCE influences directly on your 
# game's performace. The bigger is the picture, the slower it will be to
# draw it dynamically. The recommended maximum size is 200x200 pixels
# 
#-------------------------------------------------------------------------------
# * WARNING - Light pictures
#-------------------------------------------------------------------------------
# In order to run this script correctly, the light pictures MUST obey the
# following conditions:
# 1. The picture's size MUST be multiple of 2. Example: 150x150
# 2. The picture's width MUST be equal to it's height. Example: 156x156
# 3. The picture's colors MUST be inverted! This is necessary because
#    the script inverts the colors to draw the effect. The black color
#    will be transparent!
#
#-------------------------------------------------------------------------------
# * Instructions - 1. Setup your effects!
#-------------------------------------------------------------------------------
# In order to setup your static effects, go to the setup part and define your
# effects inside the Effects hash. Do as the following mode:
#
# X => [picture,opacity,variation,cut],   <= Remember to put a comma here!
#
# Where:
# picture => Picture's name, inside the Graphics/Lights folder;
# opacity => Effect's opacity;
# variation => Effect's opacity variation;
# cut => Put true to cut the effect or false to don't;
# X => The effect's ID, it will be used on events. 
#
# Check the default effects to understand how they work.
#
#-------------------------------------------------------------------------------
# * Instructions - 2. Use your effects!
#-------------------------------------------------------------------------------
# In order to use a effect, put the following comment on a event:
# 
# [light x]
#
# Where x must be the Effect's ID.
# 
#-------------------------------------------------------------------------------
# * Instructions - 3. Use an awesome lantern!
#-------------------------------------------------------------------------------
# The dynamic light source (lantern) is initialized invisible by default. 
# You may call the following commands:
# 
# l = $game_map.lantern
# Gets the lantern into a variable

# l.set_graphic(i)
# Sets the lantern's graphic to i, where i must be the picture's file name on 
# Graphics/Lights folder.
#
# l.set_multiple_graphics(h)
# Sets the lantern's graphics to h, where h must be a hash with the following
# structure:
#
# h = {2=>"ld",4=>"ll",6=>"lr",8=>"lu"}
# 
# Where: 
# "ld" is the name of the picture when the lantern's owner is looking down;
# "ll" is the name of the picture when the lantern's owner is looking left;
# "lr" is the name of the picture when the lantern's owner is looking right;
# "lu" is the name of the picture when the lantern's owner is looking up.
#
# l.change_owner(char)
# Sets the lantern's owner to char. Char must be ONE of the following commands:
# $game_player           <= The player itself;
# self_event             <= The event where the command was called;
# $game_map.events[x]    <= The event ID x.
#
# l.set_opacity(o,p)
# Sets the lantern's opacity, where:
# o is the opacity itself;
# p is the opacity variation.
#
# l.show
# After setting the lantern with the commands above, you may set it to visible
# using this command.
#
# l.hide
# Use this command to set the lantern as invisible.
#
#-------------------------------------------------------------------------------
# * Instructions - 4. Use the effect's surface!
#-------------------------------------------------------------------------------
# The Awesome Light Effects draws the effects on a surface. In order to make
# the effects visible, the effect's surface MUST be visible. The Effect's 
# Surface is initialized with it's opacity set to zero. You can call the
# following commands:
#
# s = $game_map.effect_surface
# Gets the Effect's Surface into a variable
#
# s.set_color(r,g,b)
# Changes the Effect's Surface color instantly, where:
# r => red level;
# g => green level;
# b => blue level;
#
# s.set_alpha(a)
# Changes the Effect's Surface opacity instantly to a.
#
# s.change_color(time,r,g,b)
# Changes the Effect's Surface color ONLY in a certain time, where:
# time => The change's time (frames);
# r => red level;
# g => green level;
# b => blue level;
#
# s.change_color(time,r,g,b,a)
# Changes the Effect's Surface color and it's opacity in a certain time, where:
# time => The change's time (frames);
# r => red level;
# g => green level;
# b => blue level;
# a => opacity
#
# s.change_alpha(time,a)
# Changes the Effect's Surface opacity in a certain time, where:
# time => The change's time (frames);
# a => opacity
#
#-------------------------------------------------------------------------------
# * Instructions - 5. Use the effect's surface with Tone command!
#-------------------------------------------------------------------------------
# You can access the Effect's Surface with the "Screen Tone" command. In order
# to turn this feature on, set the "Surface_UE" constant to true.
#
# If you decided to use this feature, please note some details:
# 1. The colors values must be between 0 and 255;
# 2. The time is in frames;
# 3. The "gray" value will be sent as the opacity value
#
#-------------------------------------------------------------------------------
# * Instructions - 6. Setup your Tileset Tags!
#-------------------------------------------------------------------------------
# In order to cut the effect's picture correctly, there's 3 types of behavior
# for a tile: wall, block and roof. Walls will make shadows as real walls, 
# blocks as blocks and roofs as roofs. So, the tileset tags MUST be configured.
# Check the demo to understand how this system works. If the tilesets aren't 
# configured correctly, the script won't cut the effects correctly.
# 
#-------------------------------------------------------------------------------
# * Setup Part
#-------------------------------------------------------------------------------
module Light_Core
  Effects = { #  <= DON'T change this!
#-------------------------------------------------------------------------------
# PUT YOUR EFFECTS HERE!
#-------------------------------------------------------------------------------
  0 => ["light",255,0,true],
  1 => ["torch",200,20,true],
  2 => ["torch_m",180,30,true],
  3 => ["light_s",255,0,true],
  
#-------------------------------------------------------------------------------
# End of effecs configuration
#------------------------------------------------------------------------------- 
  } #  <= DON'T change this!
  
  # Z coordinate of the Effect's Surface
  Surface_Z = 50
  
  # Enable Effect's Surface control by "Screen Tone" command?
  Surface_UE = true
  
  # Roof behavior tag
  Roof_Tag = 5
  # Wall behavior tag
  Wall_Tag = 6
  # Block behavior tag
  Block_Tag = 7
  
  # Don't change this!
  ACC = Math.tan(Math::PI/26)
end
#-------------------------------------------------------------------------------
# Script
#-------------------------------------------------------------------------------
module Cache
  def self.light(filename)
    load_bitmap("Graphics/Lights/", filename)
  end
end
module Light_Bitcore
  include Light_Core
  def self.initialize
    @@buffer = {}
    Effects.values.each { |effect| Light_Bitcore.push(effect[0])}
  end
  def self::[](key)
    return @@buffer[key]
  end
  def self.push(key)
    return if @@buffer.keys.include?(key)
    @@buffer[key] = Cache.light(key)
  end
end
Light_Bitcore.initialize
class Light_SSource
  attr_reader :real_x
  attr_reader :real_y
  attr_reader :range
  attr_accessor :bitmap
  attr_reader :w
  attr_reader :h
  attr_reader :hs
  def initialize(char,bitmap,opacity,plus,hs)
    sync(char)
    @key = bitmap
    @bitmap = Light_Bitcore[@key].clone
    @range = @bitmap.width/2
    @w = @bitmap.width
    @h = @bitmap.height
    @mr = @range - 16
    @opacity = opacity
    @plus = plus
    @hs = hs
    render if @hs
  end
  def render
    tx = x
    ty = y
    tsx = x + @range
    tsy = y + @range
    dr = @range*2
    for s in $game_map.surfaces
      next if !s.visible?(tsx,tsy) || !s.within?(tx,tx+dr,ty,ty+dr)
      s.render_shadow(tx,ty,tsx,tsy,@range,@bitmap)
    end
  end
  def restore
    return unless @bitmap.nil?
    @bitmap = Light_Bitcore[@key].clone
    render if @hs
  end
  def opacity
    @plus == 0 ? @opacity : (@opacity + rand(@plus))
  end
  def sx
    return $game_map.adjust_x(@real_x)*32-@mr
  end
  def sy
    return $game_map.adjust_y(@real_y)*32-@mr
  end
  def sync(char)
    @real_x = char.real_x
    @real_y = char.real_y
  end
  def x
    return (@real_x*32 - @mr).to_f
  end
  def y
    return (@real_y*32 - @mr).to_f
  end
  def dispose
    return if @bitmap.nil?
    @bitmap.dispose
    @bitmap = nil
  end
end
class Light_DSource < Light_SSource
  attr_reader :bitmap
  attr_reader :visible
  def initialize
    @key = nil
    @bitmap = nil
    @opacity = 255
    @plus = 0
    @char = $game_player
    @visible = false
  end
  def set_opacity(o,p)
    @opacity = o
    @plus = p
  end
  def set_graphic(sb)
    dispose
    @key = {2=>sb,4=>sb,6=>sb,8=>sb}
    Light_Bitcore.push(sb)
    @bitmap = {2=>Light_Bitcore[@key[2]].clone,4=>Light_Bitcore[@key[4]].clone,6=>Light_Bitcore[@key[6]].clone,8=>Light_Bitcore[@key[8]].clone}
    @range = @bitmap[2].width/2
    @w = @bitmap[2].width
    @h = @bitmap[2].height
    @mr = @range - 16
  end
  def set_multiple_graphics(ba)
    dispose
    @key = ba
    @key.values.each {|key| Light_Bitcore.push(key)}
    @bitmap = {2=>Light_Bitcore[@key[2]].clone,4=>Light_Bitcore[@key[4]].clone,6=>Light_Bitcore[@key[6]].clone,8=>Light_Bitcore[@key[8]].clone}
    @range = @bitmap[2].width/2
    @w = @bitmap[2].width
    @h = @bitmap[2].height
    @mr = @range - 16
  end
  def get_graphic
    return @bitmap[@char.direction].clone
  end
  def show
    return if @bitmap.nil?
    @visible = true
  end
  def hide
    @visible = false
  end
  def restore
    return if @key.nil?
    @key.values.each {|key| Light_Bitcore.push(key)}
    @bitmap = {2=>Light_Bitcore[@key[2]].clone,4=>Light_Bitcore[@key[4]].clone,6=>Light_Bitcore[@key[6]].clone,8=>Light_Bitcore[@key[8]].clone}
  end
  def dispose
    return if @bitmap.nil?
    @bitmap.values.each { |b| b.dispose }
    @bitmap = nil
  end
  def change_owner(char)
    @char = char
  end
  def render
  end
  def sx
    return $game_map.adjust_x(@char.real_x)*32-@mr
  end
  def sy
    return $game_map.adjust_y(@char.real_y)*32-@mr
  end
  def x
    return (@char.real_x*32 - @mr).to_f
  end
  def y
    return (@char.real_y*32 - @mr).to_f
  end
end
class Light_Surface
  def initialize
    @ta = @a = 0
    @tr = @r = 255
    @tg = @g = 255
    @tb = @b = 255
    @va = @vr = @vg = @vb = 0.0
    @timer = 0
  end
  def refresh
    return if @timer == 0
    @a += @va
    @r += @vr
    @g += @vg
    @b += @vb
    $game_map.light_surface.opacity = @a
    @timer -= 1
  end
  def change_color(time,r,g,b,a=nil)
    r = 0 if r < 0; r = 255 if r > 255
    g = 0 if g < 0; g = 255 if g > 255
    b = 0 if b < 0; b = 255 if b > 255
    unless a.nil?
      a = 0 if a < 0; a = 255 if a > 255
    end
    @timer = time
    @tr = 255-r
    @tg = 255-g
    @tb = 255-b
    @va = (a.nil? ? 0 : (a-@a).to_f/@timer)
    @vr = (@tr - @r).to_f/@timer
    @vg = (@tg - @g).to_f/@timer
    @vb = (@tb - @b).to_f/@timer
  end
  def change_alpha(time,a)
    a = 0 if a < 0; a = 255 if a > 255
    @timer = time
    @ta = a
    @vr = @vg = @vb = 0.0
    @va = (a-@a).to_f/@timer
  end
  def set_color(r,g,b)
    r = 0 if r < 0; r = 255 if r > 255
    g = 0 if g < 0; g = 255 if g > 255
    b = 0 if b < 0; b = 255 if b > 255
    @tr = @r = 255-r
    @tg = @g = 255-g
    @tb = @b = 255-b
    @va = @vr = @vg = @vb = 0.0
    @timer = 0
  end
  def set_alpha(a)
    a = 0 if a < 0; a = 255 if a > 255
    @ta = @a = a
    $game_map.light_surface.opacity = @a
    @va = @vr = @vg = @vb = 0.0
    @timer = 0
  end
  def alpha
    return @a
  end
  def color
    return Color.new(@r,@g,@b)
  end
end
class Game_Map
  include Light_Core
  attr_accessor :light_surface
  attr_accessor :light_sources
  attr_accessor :surfaces
  attr_accessor :effect_surface
  attr_accessor :lantern
  alias kbl_setup_events setup_events
  alias kbl_initialize initialize
  alias kbl_update update
  def initialize
    kbl_initialize
    @effect_surface = Light_Surface.new
    @lantern = Light_DSource.new
  end
  def update(arg)
    @effect_surface.refresh if arg
    kbl_update(arg)
  end
  def first_tag(x,y)
    tag = tileset.flags[tile_id(x,y,0)] >> 12
    return tag > 0 ? tag : 0
  end
  def setup_events
    @light_sources.nil? ? @light_sources = [] : @light_sources.clear
    setup_surfaces
    merge_surfaces
    kbl_setup_events
  end
  def setup_surfaces
    @surfaces = []
    for x in 0..(width-1)
      for y in 0..(height-1)
        tag = first_tag(x,y)
        if tag == Wall_Tag
          i = tile_id(x,y,0)
          if i & 0x02 == 0x02
            @surfaces << Block_SD.new(x*32,y*32,x*32+32,y*32)
          end
          if i & 0x04 == 0x04
            @surfaces << Block_WR.new(x*32+31,y*32,x*32+31,y*32+32)
            @surfaces << Block_IL.new(x*32+32,y*32,x*32+32,y*32+32)
          end
          if i & 0x01 == 0x01
            @surfaces << Block_IR.new(x*32-1,y*32,x*32-1,y*32+32)
            @surfaces << Block_WL.new(x*32,y*32,x*32,y*32+32)
          end
        elsif tag == Roof_Tag
          i = tile_id(x,y,0)
          @surfaces << Block_SU.new(x*32,y*32,x*32+32,y*32) if i & 0x02 == 0x02
          @surfaces << Block_SR.new(x*32+31,y*32,x*32+31,y*32+32) if i & 0x04 == 0x04
          @surfaces << Block_SL.new(x*32,y*32,x*32,y*32+32) if i & 0x01 == 0x01
        elsif tag == Block_Tag
          f = tileset.flags[tile_id(x,y,0)]
          @surfaces << Block_SL.new(x*32,y*32,x*32,y*32+32) if f & 0x02 == 0x02
          @surfaces << Block_SR.new(x*32+31,y*32,x*32+31,y*32+32) if f & 0x04 == 0x04
          @surfaces << Block_SU.new(x*32,y*32,x*32+32,y*32) if f & 0x08 == 0x08
        end
      end
    end
  end
  def merge_surfaces
    new_surfaces = []
    hs = []; vs = []
    ws = []; is = []
    for surface in @surfaces
      if surface.type & 0x05 == 0
        hs << surface
      else
        if surface.type & 0x010 == 0
          vs << surface
        else
          if surface.type & 0x08 == 0
            ws << surface
          else
            is << surface
          end
        end
      end
    end
    for surface in hs
      surface.ready ? next : surface.ready = true
      for s in hs
        next if s.ready || s.y1 != surface.y1 || surface.type != s.type
        if s.x2 == surface.x1
          surface.x1 = s.x1
          s.trash = true
          s.ready = true
          surface.ready = false
        elsif s.x1 == surface.x2
          surface.x2 = s.x2
          s.trash = true
          s.ready = true
          surface.ready = false
        end
      end
    end
    hs.each { |s| @surfaces.delete(s) if s.trash}
    for surface in vs
      surface.ready ? next : surface.ready
      for s in vs
        next if s.ready || s.x1 != surface.x1
        if s.y2 == surface.y1
          surface.y1 = s.y1
          s.trash = true
          s.ready = true
          surface.ready = false
        elsif s.y1 == surface.y2
          surface.y2 = s.y2
          s.trash = true
          s.ready = true
          surface.ready = false
        end
      end
    end
    vs.each { |s| @surfaces.delete(s) if s.trash}
    for surface in ws
      surface.ready ? next : surface.ready
      for s in ws
        next if s.ready || s.x1 != surface.x1
        if s.y2 == surface.y1
          surface.y1 = s.y1
          s.trash = true
          s.ready = true
          surface.ready = false
        elsif s.y1 == surface.y2
          surface.y2 = s.y2
          s.trash = true
          s.ready = true
          surface.ready = false
        end
      end
    end
    ws.each { |s| @surfaces.delete(s) if s.trash}
    for surface in is
      surface.ready ? next : surface.ready
      for s in is
        next if s.ready || s.x1 != surface.x1
        if s.y2 == surface.y1
          surface.y1 = s.y1
          s.trash = true
          s.ready = true
          surface.ready = false
        elsif s.y1 == surface.y2
          surface.y2 = s.y2
          s.trash = true
          s.ready = true
          surface.ready = false
        end
      end
    end
    is.each { |s| @surfaces.delete(s) if s.trash}
  end
end
class Game_Event < Game_Character
  alias kbl_initialize initialize
  alias kbl_setup_page setup_page
  def initialize(m,e)
    @light = nil
    @rect = Rect.new(0,0,0,0)
    kbl_initialize(m,e)
  end
  def setup_page(np)
    kbl_setup_page(np)
    setup_light(np.nil?)
  end
  def setup_light(dispose)
    unless @light.nil?
      $game_map.light_sources.delete(self)
      @light.dispose
      @light = nil
    end
    unless dispose && @list.nil?
      for command in @list
        if command.code == 108 && command.parameters[0].include?("[light")
          command.parameters[0].scan(/\[light ([0.0-9.9]+)\]/)
          effect = Light_Core::Effects[$1.to_i]
          @light = Light_SSource.new(self,effect[0],effect[1],effect[2],effect[3])
          $game_map.light_sources << self
          return
        end
      end
    end
  end
  def draw_light
    return if @light.sx > Graphics.width && @light.sy > Graphics.height && @light.sx + w < 0 && @light.sy + h < 0
    @rect.width = @light.w unless @rect.width == @light.w
    @rect.height = @light.h unless @rect.height == @light.h
    $game_map.light_surface.bitmap.blt(@light.sx,@light.sy,@light.bitmap,@rect,@light.opacity)
  end
  def dispose_light
    @light.dispose
  end
  def restore_light
    @light.restore
  end
end
if Light_Core::Surface_UE
  class Game_Interpreter
    def command_223
      $game_map.effect_surface.change_color(@params[1],@params[0].red,@params[0].green,@params[0].blue,@params[0].gray)
      wait(@params[1]) if @params[2]
    end
  end
end
class Game_Interpreter
  def self_event
    return $game_map.events[@event_id]
  end
end
class Block_Surface
  include Light_Core
  attr_accessor :x1
  attr_accessor :y1
  attr_accessor :x2
  attr_accessor :y2
  attr_accessor :ready
  attr_accessor :trash
  def initialize(x1,y1,x2,y2)
    @x1 = x1
    @y1 = y1
    @x2 = x2
    @y2 = y2
    @ready = false
    @trash = false
  end
  def within?(min_x,max_x,min_y,max_y)
    return @x2 > min_x && @x1 < max_x && @y2 > min_y && @y1 < max_y
  end
end
class Block_SL < Block_Surface
  attr_reader :type
  def initialize(x1,y1,x2,y2)
    super(x1,y1,x2,y2)
    @type = 0x01
  end
  def visible?(sx,sy)
    return sx < @x1 
  end
  def render_shadow(phx,phy,sx,sy,range,bitmap)
    @m1 = (@y1-sy)/(@x1-sx)
    @n1 = sy - @m1*sx
    @m2 = (@y2-sy)/(@x2-sx)
    @n2 = sy - @m2*sx
    for x in @x1..(sx+range)
      init = shadow_iy(x)
      bitmap.clear_rect(x-phx,init-phy,1,shadow_fy(x)-init+3)
    end
  end
  def shadow_iy(x)
    return @m1*x+@n1
  end
  def shadow_fy(x)
    return @m2*x+@n2
  end
end
class Block_SR < Block_Surface
  attr_reader :type
  def initialize(x1,y1,x2,y2)
    super(x1,y1,x2,y2)
    @type = 0x04
  end
  def visible?(sx,sy)
    return sx > @x1 
  end
  def render_shadow(phx,phy,sx,sy,range,bitmap)
    @m1 = (@y1-sy)/(@x1-sx)
    @n1 = sy - @m1*sx
    @m2 = (@y2-sy)/(@x2-sx)
    @n2 = sy - @m2*sx
    for x in (sx-range).to_i..@x1
      init = shadow_iy(x)
      bitmap.clear_rect(x-phx,init-phy,1,shadow_fy(x)-init+3)
    end
  end
  def shadow_iy(x)
    return @m1*x+@n1
  end
  def shadow_fy(x)
    return @m2*x+@n2
  end
end
class Block_IL < Block_Surface
  attr_reader :type
  def initialize(x1,y1,x2,y2)
    super(x1,y1,x2,y2)
    @type = 0x019
  end
  def visible?(sx,sy)
    return sx < @x1 && sy > @y1
  end
  def render_shadow(phx,phy,sx,sy,range,bitmap)
    @m1 = (@y1-sy)/(@x1-sx)
    @n1 = @y1 - @m1*@x1
    @m2 = (@y2-sy)/(@x2-sx)
    @m2 = 0 if @m2 > 0
    @n2 = @y2 - @m2*@x2
    for x in @x1..(sx+range)
      init = shadow_iy(x).floor
      bitmap.clear_rect(x-phx,init-3-phy,1,shadow_fy(x)-init+3)
    end
  end
  def shadow_iy(x)
    return @m1*x+@n1
  end
  def shadow_fy(x)
    return @m2*x+@n2
  end
end
class Block_IR < Block_Surface
  attr_reader :type
  def initialize(x1,y1,x2,y2)
    super(x1,y1,x2,y2)
    @type = 0x01c
  end
  def visible?(sx,sy)
    return sx > @x1 && sy > @y1
  end
  def render_shadow(phx,phy,sx,sy,range,bitmap)
    @m1 = (@y1-sy)/(@x1-sx)
    @n1 = @y1 - @m1*@x1
    @m2 = (@y2-sy)/(@x2-sx)
    @m2 = 0 if @m2 < 0
    @n2 = @y2 - @m2*@x2
    for x in (sx-range).to_i..@x1
      init = shadow_iy(x).floor
      bitmap.clear_rect(x-phx,init-3-phy,1,shadow_fy(x)-init+3)
    end
  end
  def shadow_iy(x)
    return @m1*x+@n1
  end
  def shadow_fy(x)
    return @m2*x+@n2
  end
end
class Block_WL < Block_Surface
  attr_reader :type
  def initialize(x1,y1,x2,y2)
    super(x1,y1,x2,y2)
    @type = 0x011
  end
  def visible?(sx,sy)
    return sx < @x1 && sy < @y2
  end
  def render_shadow(phx,phy,sx,sy,range,bitmap)
    @m1 = (@y1-sy)/(@x1-sx)
    @n1 = sy - @m1*sx
    @m2 = (@y2-sy)/(@x2-sx)
    @n2 = sy - @m2*sx
    for x in @x1..(sx+range)
      init = shadow_iy(x)
      bitmap.clear_rect(x-phx,init-phy,1,shadow_fy(x)-init+2)
    end
  end
  def shadow_iy(x)
    return @m1*x+@n1
  end
  def shadow_fy(x)
    return @m2*x+@n2
  end
end
class Block_WR < Block_Surface
  attr_reader :type
  def initialize(x1,y1,x2,y2)
    super(x1,y1,x2,y2)
    @type = 0x014
  end
  def visible?(sx,sy)
    return sx > @x1 && sy < @y2
  end
  def render_shadow(phx,phy,sx,sy,range,bitmap)
    @m1 = (@y1-sy)/(@x1-sx)
    @n1 = sy - @m1*sx
    @m2 = (@y2-sy)/(@x2-sx)
    @n2 = sy - @m2*sx
    for x in (sx-range).to_i..@x1
      init = shadow_iy(x)
      bitmap.clear_rect(x-phx,init-phy,1,shadow_fy(x)-init+2)
    end
  end
  def shadow_iy(x)
    return @m1*x+@n1
  end
  def shadow_fy(x)
    return @m2*x+@n2
  end
end
class Block_SU < Block_Surface
  attr_reader :type
  def initialize(x1,y1,x2,y2)
    super(x1,y1,x2,y2)
    @type = 0x02
  end
  def visible?(sx,sy)
    return sy < @y1
  end
  def render_shadow(phx,phy,sx,sy,range,bitmap)
    if @x1 == sx
      @m1 = nil
    else
      @m1 = (@y1-sy)/(@x1-sx)
      @m1 += ACC if @m1 < -ACC
      @n1 = @y1 - @m1*@x1
    end
    if @x2 == sx
      @m2 = nil
    else
      @m2 = (@y2-sy)/(@x2-sx)
      @n2 = sy - @m2*sx
    end
    for y in @y1..(sy+range)
      init = shadow_ix(y)
      bitmap.clear_rect(init-phx,y-phy,shadow_fx(y)-init+1,1)
    end
  end
  def shadow_ix(y)
    return @m1.nil? ? @x1 : (y-@n1)/@m1
  end
  def shadow_fx(y)
    return @m2.nil? ? @x2 : (y-@n2)/@m2
  end
end
class Block_SD < Block_Surface
  attr_reader :type
  def initialize(x1,y1,x2,y2)
    super(x1,y1,x2,y2)
    @type = 0x08
  end
  def visible?(sx,sy)
    return sy > @y1
  end
  def render_shadow(phx,phy,sx,sy,range,bitmap)
    if @x1 == sx
      @m1 = nil
    else
      @m1 = (@y1-sy)/(@x1-sx)
      @m1 -= ACC if @m1 > ACC
      @n1 = sy - @m1*sx
    end
    if x2 == sx
      @m2 = nil
    else
      @m2 = (@y2-sy)/(@x2-sx)
      @n2 = sy - @m2*sx
    end
    for y in (sy-range).to_i..@y1
      init = shadow_ix(y)
      bitmap.clear_rect(init-phx,y-phy,shadow_fx(y)-init+1,1)
    end
  end
  def shadow_ix(y)
    return @m1.nil? ? @x1 : (y-@n1)/@m1
  end
  def shadow_fx(y)
    return @m2.nil? ? @x2 : (y-@n2)/@m2
  end
end
class Spriteset_Map
  include Light_Core
  alias kbl_initialize initialize
  alias kbl_update update
  alias kbl_dispose dispose
  alias kbl_adapt_screen adapt_screen
  def initialize
    setup_lights
    kbl_initialize
  end
  def update
    kbl_update
    update_lights
  end
  def adapt_screen
    kbl_adapt_screen
    dispose_lights
    setup_lights
  end
  def dispose
    kbl_dispose
    dispose_lights
  end
  def dispose_lights
    $game_map.lantern.dispose
    $game_map.light_sources.each { |source| source.dispose_light }
    $game_map.light_surface.bitmap.dispose
    $game_map.light_surface.dispose
    $game_map.light_surface = nil
  end
  def update_lights
    $game_map.light_surface.bitmap.clear
    $game_map.light_surface.bitmap.fill_rect(0,0,Graphics.width,Graphics.height,$game_map.effect_surface.color)
    $game_map.light_sources.each { |source| source.draw_light }
    return unless $game_map.lantern.visible
    @btr = $game_map.lantern.get_graphic
    x = $game_map.lantern.x
    y = $game_map.lantern.y
    r = $game_map.lantern.range
    sx = x + r
    sy = y + r
    dr = r*2
    $game_map.surfaces.each { |s| s.render_shadow(x,y,sx,sy,r,@btr) if s.visible?(sx,sy) && s.within?(x,x+dr,y,y+dr) }
    $game_map.light_surface.bitmap.blt($game_map.lantern.sx,$game_map.lantern.sy,@btr,Rect.new(0,0,dr,dr),$game_map.lantern.opacity)
  end
  def setup_lights
    @btr = nil
    $game_map.lantern.restore
    $game_map.light_sources.each { |source| source.restore_light }
    $game_map.light_surface = Sprite.new
    $game_map.light_surface.bitmap = Bitmap.new(Graphics.width,Graphics.height)
    $game_map.light_surface.bitmap.fill_rect(0,0,Graphics.width,Graphics.height,$game_map.effect_surface.color)
    $game_map.light_surface.blend_type = 2
    $game_map.light_surface.opacity = $game_map.effect_surface.alpha
    $game_map.light_surface.z = Surface_Z
  end
end