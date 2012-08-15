#==============================================================================
# Particle System
#
# 粒子系统（必须配合粒子的Field类使用）
#------------------------------------------------------------------------------
# version: 1.1.15
#------------------------------------------------------------------------------
# date: 2005.10.2
#------------------------------------------------------------------------------
# by FantasyDR
#==============================================================================

class Particle
  #-============================================-#
  #■系统常量，可以用‘Particle::常量名’调用
  #-============================================-#
  #默认的屏幕相关形状，以及粒子的Z坐标
  #-----------------------------------------------
  SCREEN_Z      = 20001
  SCREEN_X      = 0
  SCREEN_Y      = 0
  SCREEN_WIDTH  = 640
  SCREEN_HEIGHT = 480
  #-----------------------------------------------
  #粒子初始化模式
  #-----------------------------------------------
  TYPE_DEFAULT  = 0            #顺序产生粒子
  TYPE_SAMETIME = 1            #一起产生粒子
  TYPE_RANDOM   = 2            #粒子寿命随机
  
  #-============================================-#
  #■默认属性
  #（建立对象的时候设定，部分也可以单独设定）
  #-============================================-#
  attr_reader :viewport           #粒子活动的vp
  attr_reader :range              #屏幕显示范围
  attr_reader :visible            #是否显示粒子
  attr_reader :buttom             #屏幕范围
  attr_reader :top                #屏幕范围
  attr_reader :left               #屏幕范围
  attr_reader :right              #屏幕范围
  attr_reader :center_x           #中心到左上偏移x
  attr_reader :center_y           #中心到左上偏移y
  attr_reader :color              #屏幕范围
  attr_reader :tone               #屏幕范围
  attr_reader :delay              #粒子的时间间隔
  
  attr_accessor :freeze           #是否冻结
  attr_accessor :opacity_max      #闪烁范围
  attr_accessor :opacity_min      #闪烁范围
  attr_accessor :flash_rate       #闪烁帧数
  attr_accessor :field            #field
  
  #-============================================-#
  #■系统属性
  #(调用set方法的时候设定，大部分也可以单独设定)
  #-============================================-#
  attr_reader :start_x
  attr_reader :start_y
  attr_reader :sysTime            #系统时间
  attr_reader :count              #粒子数量
  attr_reader :isRandTone         #初始化是否随机色调
  attr_reader :isRandColor        #初始化是否随机颜色
  attr_reader :pImg               #粒子图片
  
  attr_accessor :isFlash          #是否闪烁的标志
  attr_accessor :wind             #风力加速度，横向速度叠加
  attr_accessor :gx               #阻力加速度，横向影响
  attr_accessor :gy               #重力加速度，纵向影响
  attr_accessor :speed            #初速
  attr_accessor :life             #生命周期
  attr_accessor :t_start_x        #粒子源位置X
  attr_accessor :t_start_y        #粒子源位置Y
  attr_accessor :cycle_angle      #转动角度，0则不转动
  attr_accessor :zoom_x           #x轴缩放速率
  attr_accessor :zoom_y           #y轴缩放速率
  attr_accessor :zoom_ox          #x轴初始倍率
  attr_accessor :zoom_oy          #y轴初始倍率
  attr_accessor :rand_range       #随机角度范围
  attr_accessor :start_angle      #角度起始点
  attr_accessor :ini_type         #初始化种类
  attr_accessor :mast_in_screen   #显示在屏幕内存活
  #-============================================-#
  #■粒子属性(在后面加[id]后，按照id访问)
  #-============================================-#
  attr_reader :px                 #x向位移
  attr_reader :py                 #y向位移
  attr_accessor :timer            #计时器
  attr_accessor :sx               #横向速度
  attr_accessor :sy               #纵向速度
  attr_accessor :sa               #速度方向
  attr_accessor :fix              #透明度变化
  attr_accessor :particle         #初始化粒子
  #-============================================-#
  #■实例化对象，可以传入显示粒子的viewport
  #-============================================-#
  def initialize(viewport=nil)
    @field = Field_Base.new(self)
    @viewport=viewport
    if @viewport==nil
      self.range=Rect.new(0, 0, Graphics.width, Graphics.height)
    else
      self.range=@viewport.rect
    end
    @visible = true
    @opacity_max=255
    @opacity_min=0
    @flash_rate=10
    @dispose = true
    @delay = 1
    @freeze = false
    @zoom_ox=1
    @zoom_oy=1
    
    @timer =[1]
    @sx =[0.1]
    @sy =[0.1]
    @sa =[0.1]
    @px =[0.1]
    @py =[0.1]
    @fix =[0.1]
    @particle =[]
  end
  
  #-============================================-#
  #■count=方法，设置粒子数量
  #-============================================-#
  def count=(count)
    if count<=0 || count == @count
      return
    end
    if count<@count
      min = count
      max = @count-1
      for i in min..max
        @particle[i].dispose
      end
    end
    if count>@count
      min = @count
      max = count-1
      for i in min..max
        @particle[i] = Sprite.new(@viewport)
        @particle[i].bitmap = @pImg
      end
    end
    @count=count
    return
  end
  #-============================================-#
  #■delay=方法，设置粒子重生间隔
  #-============================================-#
  def delay=(r)
    @delay=r
    if @delay<0
      @delay=0
    end
  end
  #-============================================-#
  #■enable=方法，同时控制visible和freeze
  #-============================================-#
  def enable=(b)
    self.visible=b
    @freeze=!b
  end
  #-============================================-#
  #■enable方法，返回现在状态
  #-============================================-#
  def enable
    return ((!@freeze) && @visible)
  end
  #-============================================-#
  #■visible=方法，设置粒子是否显示
  #-============================================-#
  def visible=(b) 
    if @count==0 or @visible == b
      return
    end
    @visible=b
    max = @count-1
    for i in 0..max
      if timer[i]>0 || particle[i].visible
        particle[i].visible=@visible
      end
    end
  end
  #-============================================-#
  #■range=方法，设置粒子活动范围range
  #-============================================-#
  def range=(r)
    @range=r
    @top=r.y
    @left=r.x
    @right=r.x+r.width-1
    @buttom=r.y+r.height-1
  end
  #-============================================-#
  #■pImg=方法，设置粒子图像
  #-============================================-#
  def pImg=(r)
    if r == nil
      return
    end
    @pImg=r
    @center_x= @pImg.width/2 -1
    @center_y= @pImg.height/2 -1
    if @count==0
      return
    end
    for i in 0..@count-1
      particle[i].bitmap = @pImg
    end
  end
  #-============================================-#
  #■isRandTone=方法，产生随机色调
  #-============================================-#
  def isRandTone=(r)
    if @count==0
      return
    end
    @isRandTone=r
    max = @count-1
    if @isRandTone
      for i in 0..max
        @particle[i].tone = Tone.new(rand(255),rand(255),rand(255),rand(255))
      end
    else
      for i in 0..max
        @particle[i].tone = @tone
      end
    end
  end
  #-============================================-#
  #■isRandColor=方法，设置随机颜色
  #-============================================-#
  def isRandColor=(r)
    if @count==0
      return
    end
    @isRandColor=r
    max = @count-1
    if @isRandColor
      for i in 0..max
        @particle[i].color = Color.new(rand(255),rand(255),rand(255))
      end
    else
      for i in 0..max
        @particle[i].color = @color
      end
    end
  end
  #-============================================-#
  #■tone=方法，设置粒子显示色调
  #-============================================-# 
  def tone=(t)
    if @count==0
      return
    end
    @tone=t
    max = @count-1
    for i in 0..max
      particle[i].tone=@tone
    end
  end
  #-============================================-#
  #■color=方法，设置粒子叠加颜色
  #-============================================-#
  def color=(c)
    if @count==0
      return
    end
    @color=c
    max = @count-1
    for i in 0..max
      particle[i].color=@color
    end
  end
  #-============================================-#
  #■zoom=方法，设置粒子缩放倍率
  #-============================================-#
  def zoom=(z)
    if @count==0 || z<0
      return
    end
    max = @count-1
    for i in 0..max
      @zoom_ox=z
      @zoom_oy=z
    end
  end
  #-============================================-#
  #■dispose?方法，被释放，或者没有初始化返回true
  #-============================================-# 
  def dispose?
    @dispose
  end
  #-============================================-#
  #■dispose方法，释放对象
  #-============================================-# 
  def dispose
    if !@dispose
      max = @count-1
      for i in 0..max
        particle[i].dispose
      end
      #@pImg.dispose
    end
    @dispose = true
  end
  #-============================================-#
  #■set方法，初始化系统
  #----------------------------------------------
  #（必要参数列表，参数解释与set的参数一一对应）
  #----------------------------------------------
  # 初始化种类(0~2，或者使用类的常量Particle::TYPE_DEFAULT等）
  # 是否出屏幕就终止生命，
  # 系统风力，
  # 水平加速度
  # 垂直加速度，
  # 粒子数量，
  # 粒子初速度，
  # 粒子生命周期，
  # 粒子源X坐标，
  # 粒子源Y坐标
  #----------------------------------------------
  #（有默认值的参数列表）
  #（关于旋转的参数，单位是角度，逆时针）
  #----------------------------------------------
  # 粒子图片，
  # 粒子旋转角度（0为不旋转）
  # 发射角度起始（默认垂直向上），
  # 发射角变化范围（默认0）
  # 运动是闪耀(true)还是渐渐消失(false)
  # 是否有随机色调，
  # 是否有随机颜色，
  # 横向的收缩率，
  # 纵向的收缩率（添负数就放大）
  #-============================================-#
  def       set(ini_type,mast_in_screen,wind, gravity_x, gravity_y,\
      particle_number, particle_speed,\
      particle_life,  start_x,  start_y,\
      particle_image = Bitmap.new(24,24),cycle_angle = 0,\
      start_angle = 270,rand_range = 0,\
      is_flash = false,\
      is_random_tone = false,is_random_color=false,\
      zoom_x = 0.01,zoom_y = 0.01)
    if !@dispose
      self.dispose
    end
    @count = 0
    self.count=particle_number
    
    @mast_in_screen = mast_in_screen
    @ini_type = ini_type
    @wind =wind
    @gx =gravity_x
    @gy =gravity_y
    @speed =particle_speed
    @life =particle_life
    @start_x = start_x
    @start_y = start_y
    @t_start_x = start_x
    @t_start_y = start_y
    self.pImg = particle_image
    
    self.zoom = 1
    @opacity_max = 255
    @opacity_min = 0
    @rand_range = rand_range
    @start_angle  = start_angle
    @zoom_x =zoom_x
    @zoom_y =zoom_y
    @cycle_angle =cycle_angle     
    
    @isFlash =is_flash
    @color=Color.new(0,0,0,0)
    @tone=Tone.new(0,0,0,0)
    self.isRandTone=is_random_tone
    self.isRandColor=is_random_color
    
    @dispose=false
    self.reset
  end
  #-============================================-#
  #■初始化所有粒子
  #-============================================-#
  def reset
    if @dispose
      return
    end
    @freeze = false
    @sysTime = 0
    max = @count-1
    for i in 0..max
      @particle[i].z = SCREEN_Z          
      case @ini_type
      when TYPE_SAMETIME
        @particle[i].visible = false
        @timer[i] = -@field.get_delay(i)
      else
        @particle[i].visible = false
        @timer[i] = -(@count-i) * @field.get_delay(i)
      end
    end
  end
  #-============================================-#
  #■初始化某个粒子
  #-============================================-#
  def p_reset(i)
    if @dispose
      return
    end
    @field.reset(i)
    case @ini_type
    when TYPE_RANDOM
      @timer[i] = rand(@life)+1
    else
      @timer[i] = @field.get_life(i)
    end
    @particle[i].visible = @visible
    @start_x=@field.get_start_x(i)
    @start_y=@field.get_start_y(i)
    
    @px[i] = @start_x
    @py[i] = @start_y
    @particle[i].ox = @center_x
    @particle[i].oy = @center_y
    @particle[i].opacity = @opacity_max
    @particle[i].zoom_x =@zoom_ox
    @particle[i].zoom_y =@zoom_oy
    @particle[i].x = @px[i]
    @particle[i].y = @py[i]
    @particle[i].angle = 0
    if isRandColor
      @particle[i].color = Color.new(rand(255),rand(255),rand(255))
    end
    if isRandTone
      @particle[i].tone = Tone.new(rand(255),rand(255),rand(255),rand(255))
    end
    
    @sa[i] = @field.get_sa(i)
    @sx[i] = Math::cos(@sa[i])*@field.get_speed(i)
    @sy[i] = Math::sin(@sa[i])*@field.get_speed(i)
    if @isFlash
      @fix[i] = -(@opacity_max-@opacity_min)/@flash_rate
    else
      @fix[i] = -(@opacity_max-@opacity_min)/@timer[i]
    end
  end
  
  #-============================================-#
  #■粒子处理
  #-============================================-#
  def update
    
    #不运行就退出 
    if  @freeze || @dispose
      return
    end
    
    @field.particle = self
    @sysTime += 1
    
    max = @count-1
    for i in 0..max
      #时间变化
      if @timer[i]<0
        @timer[i] +=1
      else
        @timer[i] -=1
        
        #加速度变化
        @field.gx(i)
        @field.gy(i)
        
        #透明度变化
        @field.opacity(i)
        
        #闪烁控制
        if @isFlash &&\
          (@particle[i].opacity >= @opacity_max ||\
            @particle[i].opacity<=@opacity_min)
          @fix[i] = -@fix[i]
        end
        
        #大小变化
        @field.zoom_x(i)
        @field.zoom_y(i)
        
        #速度变化
        @field.sx(i)
        @field.sy(i)     
        
        #位置变化
        @field.px(i)
        @field.py(i)
        
        @particle[i].x = @px[i]
        @particle[i].y = @py[i]
        
        #角度变化
        if @cycle_angle != 0
          @particle[i].angle += @cycle_angle
        end
      end
      
      #恢复初始状态
      if @mast_in_screen && @timer[i]>0
        if @particle[i].x <@left    ||\
          @particle[i].y <@top     ||\
          @particle[i].x >@right   ||\
          @particle[i].y >@buttom
          self.p_reset(i)
        end
      else
        if @timer[i]==1
          @timer[i] = -@field.get_delay(i)
        end
        if @timer[i]==0
          self.p_reset(i)
        end
      end
    end
  end
end