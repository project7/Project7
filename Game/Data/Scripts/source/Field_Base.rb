#==============================================================================
# 基本场（必须配合Particle类使用）
#------------------------------------------------------------------------------
# by FantasyDR
#==============================================================================
# 其他场必须继承于这个类
#==============================================================================
class Field_Base
  attr_writer :particle #所控粒子
  
  def initialize(particle)
    @particle=particle
  end
  
  #------------------------------
  #返回所控粒子的实例id
  #------------------------------
  def particle
    @particle.object_id
  end
  
  #------------------------------
  #初始化粒子时，在非TYPE_RANDOM模式下，获取粒子初始寿命
  #------------------------------
  def get_life(id)
     return @particle.life 
  end
  
  #------------------------------
  #初始化粒子时，获取粒子重生时间单位
  #------------------------------
  def get_delay(id)
    return @particle.delay
  end
  
  #------------------------------
  #初始化粒子时，获取粒子合速度
  #------------------------------
  def get_speed(id)
    return @particle.speed
  end
  
  #------------------------------
  #初始化粒子时，获取粒子起始x值
  #------------------------------
  def get_start_x(id)
    return @particle.t_start_x
  end
  
  #------------------------------
  #初始化粒子时，获取粒子起始y值
  #------------------------------
  def get_start_y(id)
    return @particle.t_start_y
  end
  
  #------------------------------
  #初始化粒子时，获取粒子速度发射角
  #------------------------------
  def get_sa(id)
    angle=(rand(@particle.rand_range)+@particle.start_angle)/180.0
    return Math::PI*angle
  end
  
  #------------------------------
  #初始化粒子前调用的场方法
  #------------------------------
  def reset(id)
    return true
  end
  
  #------------------------------
  #update前，处理粒子场横向加速度
  #------------------------------
  def gx(id)
    @particle.gx
  end
  
  #------------------------------
  #update前，处理粒子场纵向加速度
  #------------------------------
  def gy(id)
    @particle.gy
  end
  
  #------------------------------
  #update时，粒子横向缩放
  #------------------------------
  def zoom_x(id)
    if @particle.particle[id].zoom_x>=@particle.zoom_x
      @particle.particle[id].zoom_x -=@particle.zoom_x
    end
  end
  
  #------------------------------
  #update时，粒子纵向缩放
  #------------------------------
  def zoom_y(id)
    if @particle.particle[id].zoom_y>=@particle.zoom_y
      @particle.particle[id].zoom_y -=@particle.zoom_y
    end
  end  
  
  #------------------------------
  #update时，粒子透明度变化
  #------------------------------
  def opacity(id)
     @particle.particle[id].opacity += @particle.fix[id]
  end
  
  #------------------------------
  #update时，粒子横向速度变换
  #------------------------------
  def sx(id)
    @particle.sx[id] +=@particle.gx
  end
  
  #------------------------------
  #update时，粒子纵向速度变换
  #------------------------------
  def sy(id)
    @particle.sy[id] +=@particle.gy
  end
  
  #------------------------------
  #update时，粒子x坐标变化
  #------------------------------
  def px(id)
    @particle.px[id] += @particle.sx[id] + @particle.wind
  end
  
  #------------------------------
  #update时，粒子y坐标变化
  #------------------------------
  def py(id)
    @particle.py[id] += @particle.sy[id]
  end
end