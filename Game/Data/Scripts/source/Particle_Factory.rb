#==============================================================================
# Particle Factory
#
# 粒子工厂（缩写为PTCF）
#------------------------------------------------------------------------------
# by FantasyDR
#==============================================================================
# 用于根据已有的参数模板初始化粒子，省去繁琐的参数设定。
# 需要调用在Field_Template中定义的模板场。
#==============================================================================

class PTCF
  
  #-============================================-#
  #■模板常数
  # 使用set方法套用模板，就可以省去单独设置粒子。
  # 但是请保证Graphics/Icons/目录下面有所需图片。
  #-============================================-#
  Normal   = 0              #默认模板
  Fire     = 1              #样板模式－火焰
  Rain     = 2              #样板模式－雨滴
  Snow     = 3              #样板模式－雪花
  Star     = 4              #样板模式－闪耀的星
  Fountain = 5              #样板模式－喷泉
  Bomb     = 6              #样板模式－礼花
  Plant    = 7              #样式模板－行星
  Olive    = 8              #样式模板－橄榄
  Mist     = 9
  MistLight= 10
  
  #-============================================-#
  #■工厂成员
  #-============================================-#
  attr_reader :p          # 工厂粒子，用p[id]访问
  attr_reader :type       # 粒子的现用模板,用type[id]访问
  attr_reader :count      # 包含的粒子数目
  attr_reader :viewport   # 粒子的显示层
  
  
  #-============================================-#
  #■初始化粒子工厂，确定工厂包含的粒子数量
  #-============================================-# 
  def initialize(count=1,viewport=nil)
    
    if count<1  #检查粒子库数目合法性
      count = 1
    end
    @p = []
    @type = [Normal]
    for id in 0..count-1
      @p[id]=Particle.new(viewport)
    end
    @count = count
    @viewport=viewport
    set_all(Normal)
  end
  
  #-============================================-#
  #■update方法，更新工厂粒子
  #-============================================-# 
  def update()
    for id in 0..@count-1
      if @p[id] != nil
        @p[id].update
      end
    end
  end
  
  #-============================================-#
  #■dispose方法，释放资源
  #-============================================-# 
  def dispose()
    for id in 0..@count-1
      if @p[id] != nil
        @p[id].dispose
      end
    end
  end
  
  #-============================================-#
  #■template方法，用工厂模板初始化一个粒子
  #-============================================-# 
  def template(ptc,t)   
    case t
    when Normal
      ptc.field=Field_Base.new(ptc)
      ptc.set(Particle::TYPE_RANDOM,false,\
        0,0,0,30,\
        5,30,(ptc.left+ptc.right)/2,(ptc.top+ptc.buttom)/2,\
        Cache.icon("Particle_ball.png"),\
        0,0,360)
      
    when Fire
      ptc.field=Field_Fire.new(ptc)
      ptc.set(Particle::TYPE_DEFAULT,false,\
        0,0,0,50,\
        2,30,(ptc.left+ptc.right)/2,(ptc.top+ptc.buttom)/2,\
        Cache.icon("Particle_ball.png"),\
        0,255,30)
      ptc.color=Color.new(242,101,34)
      
    when Rain
      ptc.field=Field_Star.new(ptc)
      ptc.set(Particle::TYPE_RANDOM,true,\
        -1,-0.1,0.2,50,\
        3,50,0,0,\
        Cache.icon("Particle_Rain.png"),\
        0,90,0,false,false,false,\
        0,0)
      ptc.opacity_max=160
      
    when Snow
      ptc.field=Field_Snow.new(ptc)
      ptc.set(Particle::TYPE_DEFAULT,false,\
        1,0,0.15,100,\
        1,100,0,ptc.top-10,\
        Cache.icon("Particle_Snow.png"),\
        10,0,180)
      
    when Star
      ptc.field=Field_Star.new(ptc)
      ptc.set(Particle::TYPE_DEFAULT,false,\
        0,0,0,100,\
        0,100,0,0,\
        Cache.icon("Particle_ball.png"),\
        0,0,0,true)
      ptc.color=Color.new(242,101,34)
      
    when Fountain
      ptc.field=Field_Base.new(ptc)
      ptc.set(Particle::TYPE_DEFAULT,false,\
        0,0,0.4,100,\
        5,100,(ptc.left+ptc.right)/2,(ptc.top+ptc.buttom)/2,\
        Cache.icon("Particle_ball.png"),\
        0,220,120)
      ptc.color=Color.new(109,207,246)
      
    when Bomb
      ptc.field=Field_Bomb.new(ptc)
      ptc.set(Particle::TYPE_SAMETIME,false,\
        0,0,0,100,\
        5,50,(ptc.left+ptc.right)/2,(ptc.top+ptc.buttom)/2,\
        Cache.icon("Particle_ball.png"),\
        0,0,360)
      ptc.color=Color.new(255,101,34)
      
    when Plant
      ptc.field=Field_Plant.new(ptc,320,240,0.8)
      ptc.set(Particle::TYPE_RANDOM,true,\
        0,0,0,15,\
        5,500,0,0,\
        Cache.icon("Particle_BasicBlur.png"),\
        0,0,360,false,true,false,\
        0.002,0.002)
      ptc.zoom = 0.3
      #ptc.range = Rect.new(120,40,400,400)
      
    when Olive
      ptc.field = Field_Fire.new(ptc)
      ptc.set(Particle::TYPE_RANDOM,true,\
        0,0,0,50,\
        4,100,320,240,\
        Cache.icon("Particle_BasicBlur.png"),\
        20,0,360,false,true,false,\
        -0.02,-0.01)
      ptc.zoom = 0
      
    when Mist
      ptc.field=Field_Mist.new(ptc)
      ptc.set(Particle::TYPE_RANDOM,false,\
        0,0,0,100,\
        2,300,
        (ptc.left+ptc.right)/2,
        (ptc.top+ptc.buttom)/2 + 100,\
        Cache.icon("Particle_ball.png"),\
        0,0,360)
      ptc.zoom = 0.8
      ptc.opacity_max=160
      ptc.color=Color.new(108,159,155)
      
    when MistLight
      ptc.field=Field_MistLight.new(ptc)
      ptc.set(Particle::TYPE_RANDOM,false,\
        0,0,0,40,\
        0,400,0,0,\
        Cache.icon("Particle_basicblur.png"),\
        0,0,0,true,false,false,0,0)
      ptc.zoom = 1.6
      ptc.opacity_max=50
      ptc.opacity_min=0
      ptc.flash_rate=100
      ptc.color=Color.new(108,159,155)
    else
      return false
    end
    return true   
  end
  
  #-============================================-#
  #■set方法，套用粒子模板初始化粒子。
  #-============================================-# 
  def set(id,t)
    if @p[id] == nil
      @p[id] = Particle.new(@viewport)
    end
    template(@p[id],t)
    @type[id]=t
  end
  
  #-============================================-#
  #■set_all方法，套用粒子模板初始化所有粒子。
  #-============================================-# 
  def set_all(t)
    for id in 0..@count-1
      set(id,t)
    end
  end
  
  #-============================================-#
  #■visible=方法，设定所有粒子显示
  #-============================================-# 
  def visible=(visible)
    for id in 0..@count-1
      if @p[id] != nil
        @p[id].visible=visible
      end
    end
  end
  #-============================================-#
  #■enable=方法，调用粒子的enable
  #-============================================-# 
  def enable=(enable)
    for id in 0..@count-1
      if @p[id] != nil
        @p[id].enable=enable
      end
    end
  end
  #-============================================-#
  #■freeze=方法，设定所有粒子冻结
  #-============================================-# 
  def freeze=(freeze)
    for id in 0..@count-1
      if @p[id] != nil
        @p[id].freeze=freeze
      end
    end
  end
  
end