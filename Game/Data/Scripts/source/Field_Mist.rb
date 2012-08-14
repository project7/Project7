class Field_Mist < Field_Base
  POS = [[209, 253], [590, 371], [425, 361]]
  def initialize(particle)
    super
    
    @pos = {}
    @poses = POS.map do |i|
      [
        400 - i[0], 300 - i[1]
      ]
    end
  end
  def pos(id)
    @pos[id] || (
      base = @poses.sample;
      @pos[id] = [
        (@particle.left + @particle.right) / 2 + base[0] + rand(100) - 50,
        (@particle.top + @particle.buttom) / 2 + base[1] + rand(100) - 50
      ]
    )
  end
  def get_start_x(id)
    pos(id)[0]
  end
  def get_start_y(id)
    pos(id)[1]
  end
end

class Field_MistLight < Field_Star
end