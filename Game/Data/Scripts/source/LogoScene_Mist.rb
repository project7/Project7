#encoding:utf-8
class LogoScene_Mist < LogoScene_Base
  def update_extra
    @stars.update
  end
  def create_extra
    @stars= PTCF.new(1,@viewport)
    @stars.set(0, PTCF::Mist)
  end
  def dispose_extra
    @stars.dispose
  end
  def adapt_extra
    dispose_extra
    create_extra
  end
  def pic
    "LOGO-MS"
  end
end
