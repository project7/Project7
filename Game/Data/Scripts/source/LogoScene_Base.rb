#encoding:utf-8

class LogoScene_Base
  SPEED = 3
  def main
    @viewport = Viewport.new
    @viewport.tone.set(-255, -255, -255, 0)
    create_lights
    @sprite = Sprite.new(@viewport)
    @sprite.bitmap = Cache.system(pic)
    center_sprite(@sprite)
    create_extra rescue nil
    openness = -255
    loop do |i|
      openness += SPEED
      openness = 0 if openness > 0
      @viewport.tone.set(openness, openness, openness, 0)
      update_fuck
      break if openness == 0
    end
    count = 0
    loop do
      update_fuck
      break if CInput.trigger?($vkey[:Check])
      break if (count += 1) > 100
    end
    loop do |i|
      openness -= SPEED
      openness = -255 if openness < -255
      @viewport.tone.set(openness, openness, openness, 0)
      update_fuck
      break if openness == -255
    end
    @sprite.bitmap.dispose
    @sprite.dispose
    @viewport.dispose
    dispose_extra rescue nil
    dispose_lights
  end
  def create_lights
    @lights= PTCF.new(1,@viewport)
    @lights.set(0, PTCF::MistLight)
  end
  def dispose_lights
    @lights.dispose
  end
  def update_fuck
    update_extra rescue nil
    @lights.update
    @viewport.update
    @sprite.update
    Graphics.update
    CToy.update
    CInput.update
    Mouse.update
  end
  def adapt_screen
    @viewport.rect.width = Graphics.width
    @viewport.rect.height = Graphics.height
    adapt_extra rescue nil
    dispose_lights
    create_lights
    center_sprite(@sprite)
  end
  def center_sprite(sprite)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2
  end
end