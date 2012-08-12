class RPG::BGM < RPG::AudioFile
  @@last = RPG::BGM.new
  def play(pos = 0)
    if @name.empty?
      Audio.bgm_stop
      @@last = RPG::BGM.new
    else
      Audio.bgm_play('Audio/BGM/' + @name, @volume, @pitch, pos)
      @@last = self.clone
    end
  end
  def replay
    play(@pos)
  end
  def self.stop
    Audio.bgm_stop
    @@last = RPG::BGM.new
  end
  def self.fade(time)
    Audio.bgm_fade(time)
    @@last = RPG::BGM.new
  end
  def self.last
    @@last.pos = Audio.bgm_pos
    @@last
  end
  attr_accessor :pos
end

class RPG::BGS < RPG::AudioFile
  @@last = RPG::BGS.new
  def play(pos = 0)
    if @name.empty?
      Audio.bgs_stop
      @@last = RPG::BGS.new
    else
      Audio.bgs_play('Audio/BGS/' + @name, @volume, @pitch, pos)
      @@last = self.clone
    end
  end
  def replay
    play(@pos)
  end
  def self.stop
    Audio.bgs_stop
    @@last = RPG::BGS.new
  end
  def self.fade(time)
    Audio.bgs_fade(time)
    @@last = RPG::BGS.new
  end
  def self.last
    @@last.pos = Audio.bgs_pos
    @@last
  end
  attr_accessor :pos
end

class RPG::ME < RPG::AudioFile
  def play
    if @name.empty?
      Audio.me_stop
    else
      Audio.me_play('Audio/ME/' + @name, @volume, @pitch)
    end
  end
  def self.stop
    Audio.me_stop
  end
  def self.fade(time)
    Audio.me_fade(time)
  end
end

class RPG::SE < RPG::AudioFile
  def play
    unless @name.empty?
      Audio.se_play('Audio/SE/' + @name, @volume, @pitch)
    end
  end
  def self.stop
    Audio.se_stop
  end
end

class RPG::AudioFile
  def initialize(name = '', volume = 100, pitch = 100)
    @name = name
    @volume = volume
    @pitch = pitch
  end
  attr_accessor :name
  attr_accessor :volume
  attr_accessor :pitch
end

