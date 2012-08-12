#==============================================================================
# ** FMod
#------------------------------------------------------------------------------
#  A higher level module to access FMOD Ex
#==============================================================================

module FMod
  
  #============================================================================
  # ** SoundFile
  #----------------------------------------------------------------------------
  #  Represents a Sound file (BGM, BGS, SE, etc.) and associated Channel
  #============================================================================
  
  class SoundFile
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #--------------------------------------------------------------------------
    attr_accessor :name                     # File name
    attr_accessor :sound                    # FModEx::Sound object
    attr_accessor :channel                  # Channel playing sound
    attr_accessor :volume                   # Volume in RPG::AudioFile format
    attr_accessor :pitch                    # Pitch in RPG::AudioFile format
    attr_accessor :looping                  # Sound loops
    attr_accessor :streaming                # Sound is streamed
    attr_accessor :length                   # Sound length in milliseconds
    attr_accessor :base_volume              # Base volume
    #--------------------------------------------------------------------------
    # * Object Initialization
    #--------------------------------------------------------------------------
    def initialize(name, sound, channel, volume, pitch, looping, streaming, length)
      @name = name
      @sound = sound
      @base_volume = 100.0
      @channel = channel
      @volume = volume
      @pitch = pitch
      @looping = looping
      @streaming = streaming
      @length = length
    end
  end
  #--------------------------------------------------------------------------
  # * Instance Variables
  #--------------------------------------------------------------------------
  @fmod_dll = FModEx::DLL.new               # The FMOD Ex DLL
  @fmod = FModEx::System.new(@fmod_dll)     # The global System object
  @fmod_se = []                             # Array of Sound Effects
  @rtp_folder = ""                          # Name of RTP folder
  #--------------------------------------------------------------------------
  # * Return Proper File Name (With Extensions)
  #     name            : Name of the file
  #     extensions      : Extensions to add to file name
  #-------------------------------------------------------------------------- 
  def self.checkExtensions(name, extensions)
    if FileTest.exist?(name)
      return name
    end
    # Add extension if needed
    extensions.each do |ext|
      if FileTest.exist?(name + '.' + ext)
        return name + '.' + ext
      end
    end
    # File doesn't exist
    return name
  end
  #--------------------------------------------------------------------------
  # * Get Valid File Name
  #     name            : Name of the file
  #-------------------------------------------------------------------------- 
  def self.selectBGMFilename(name)
    name = name.gsub("/", "\\")
    # See if file exists in game folder
    localname = self.checkExtensions(name, FModEx::FMOD_FILE_TYPES)
    if FileTest.exist?(localname)
      return localname
    end
    # An invalid name was provided
    return name
  end
  #--------------------------------------------------------------------------
  # * Play a Sound File Then Return it
  #     name            : Name of the file
  #     volume          : Channel volume
  #     pitch           : Channel frequency
  #     position        : Starting position in milliseconds
  #     looping         : Does the sound loop?
  #     streaming       : Stream sound or load whole thing to memory?
  #-------------------------------------------------------------------------- 
  def self.play(name, volume, pitch, position, looping, streaming, base_volume = 100.0)
    # Get a valid file name
    filename = self.selectBGMFilename(name)
    # Create Sound or Stream and set initial values
    sound = streaming ? @fmod.createStream(filename) : @fmod.createSound(filename)
    sound.loopMode = looping ? FModEx::FMOD_LOOP_NORMAL : FModEx::FMOD_LOOP_OFF
    channel = sound.play
    volume = volume * 1.0
    pitch = pitch * 1.0
    file_length = sound.length(FModEx::FMOD_DEFAULT_UNIT)
    sound_file = SoundFile.new(filename, sound, channel, volume, 
                                pitch, looping, streaming, file_length)
    sound_file.base_volume = base_volume
    sound_file.channel.volume = volume * base_volume / 10000.0
    sound_file.channel.frequency = sound_file.channel.frequency * pitch / 100
    sound_file.channel.position = position
    return sound_file
  end
  #--------------------------------------------------------------------------
  # * Stop and Dispose of Sound File
  #-------------------------------------------------------------------------- 
  def self.stop(sound_file)
    unless sound_file and sound_file.channel
      return
    end
    # Stop channel, then clear variables and dispose of bgm
    sound_file.channel.stop
    sound_file.channel = nil
    sound_file.sound.dispose
  end
  #--------------------------------------------------------------------------
  # * Return Length in Milliseconds
  #-------------------------------------------------------------------------- 
  def self.get_length(sound_file, unit = FModEx::FMOD_DEFAULT_UNIT)
    return sound_file.length(unit)
  end
  #--------------------------------------------------------------------------
  # * Check if Another Sound File is Playing
  #-------------------------------------------------------------------------- 
  def self.already_playing?(sound_file, name, position = 0)
    # Get a valid file name
    filename = self.selectBGMFilename(name)
    if (sound_file)
      # If the same sound file is already playing don't play it again
      if (sound_file.name == filename and position == 0)
        return true
      end
      # If another sound file is playing, stop it
      if sound_file.channel
        self.stop(sound_file)
      end
    end
    # No sound file is playing or it was already stopped
    return false
  end
  #--------------------------------------------------------------------------
  # * Check if Sound File is Playing
  #--------------------------------------------------------------------------  
  def self.playing?(sound_file)
    unless sound_file and sound_file.channel
      return false
    end
    return sound_file.channel.playing?
  end
  #--------------------------------------------------------------------------
  # * Get Current Sound File Playing Position
  #-------------------------------------------------------------------------- 
  def self.get_position(sound_file)
    unless sound_file and sound_file.channel
      return 0
    end
    return sound_file.channel.position
  end
  #--------------------------------------------------------------------------
  # * Seek to a New Sound File Playing Position
  #-------------------------------------------------------------------------- 
  def self.set_position(sound_file, new_pos)
    unless sound_file and sound_file.channel
      return
    end
    sound_file.channel.position = new_pos
  end
  #--------------------------------------------------------------------------
  # * Get Current Sound File Volume
  #-------------------------------------------------------------------------- 
  def self.get_volume(sound_file)
    unless sound_file
      return 0
    end
    return sound_file.volume
  end
  #--------------------------------------------------------------------------
  # * Set Sound File Volume
  #-------------------------------------------------------------------------- 
  def self.set_volume(sound_file, volume)
    unless sound_file and sound_file.channel
      return
    end
    sound_file.volume = volume * 1.0
    sound_file.channel.volume = sound_file.base_volume * volume / 10000.0
  end
  #--------------------------------------------------------------------------
  # * Set Loop Points
  #     first           : Loop start point in milliseconds
  #     second          : Loop end point in milliseconds (-1 for file end)
  #     unit            : FMOD_TIMEUNIT for points
  #-------------------------------------------------------------------------- 
  def self.set_loop_points(sound_file, first, second, unit = FModEx::FMOD_DEFAULT_UNIT)
    unless sound_file and sound_file.channel
      return
    end
    # If second is -1 then set loop end to the file end
    if second == -1
      second = sound_file.length - 1
    end
    # Set loop points and reflush stream buffer
    sound_file.channel.sound.setLoopPoints(first, second, unit)
    sound_file.channel.position = sound_file.channel.position
    return sound_file
  end
  #--------------------------------------------------------------------------
  # * Play BGM (or ME)
  #     name            : Name of the file
  #     volume          : Channel volume
  #     pitch           : Channel frequency
  #     position        : Starting position in milliseconds
  #     looping         : Does the BGM loop?
  #-------------------------------------------------------------------------- 
  def self.bgm_play(name, volume, pitch, position = 0, looping = true)
    return if self.already_playing?(@fmod_bgm, name, position)
    # Now play the new BGM as a stream
    @fmod_bgm = self.play(name, volume, pitch, position, looping, true)
  end
  #--------------------------------------------------------------------------
  # * Stop and Dispose of BGM
  #-------------------------------------------------------------------------- 
  def self.bgm_stop
    self.stop(@fmod_bgm)
    @fmod_bgm = nil
  end
  #--------------------------------------------------------------------------
  # * Return BGM Length in Milliseconds
  #-------------------------------------------------------------------------- 
  def self.bgm_length(sound_file)
    self.get_length(@fmod_bgm)
  end
  #--------------------------------------------------------------------------
  # * Check if a BGM is Playing
  #--------------------------------------------------------------------------  
  def self.bgm_playing?
    return self.playing?(@fmod_bgm)
  end
  #--------------------------------------------------------------------------
  # * Get Current BGM Playing Position
  #-------------------------------------------------------------------------- 
  def self.bgm_position
    return self.get_position(@fmod_bgm)
  end
  #--------------------------------------------------------------------------
  # * Seek to New BGM Playing Position
  #-------------------------------------------------------------------------- 
  def self.bgm_position=(new_pos)
    self.set_position(@fmod_bgm, new_pos)
  end
  #--------------------------------------------------------------------------
  # * Get Current BGM Volume
  #-------------------------------------------------------------------------- 
  def self.bgm_volume
    return self.get_volume(@fmod_bgm)
  end
  #--------------------------------------------------------------------------
  # * Set BGM Volume
  #-------------------------------------------------------------------------- 
  def self.bgm_volume=(volume)
    self.set_volume(@fmod_bgm, volume)
  end
  #--------------------------------------------------------------------------
  # * Set Loop Points
  #     first           : Loop start point in milliseconds
  #     second          : Loop end point in milliseconds
  #     unit            : FMOD_TIMEUNIT for points
  #-------------------------------------------------------------------------- 
  def self.bgm_set_loop_points(first, second, unit = FModEx::FMOD_DEFAULT_UNIT)
    @fmod_bgm = self.set_loop_points(@fmod_bgm, first, second, unit)
  end
  #--------------------------------------------------------------------------
  # * Play BGS
  #     name            : Name of the file
  #     volume          : Channel volume
  #     pitch           : Channel frequency
  #     position        : Starting position in milliseconds
  #     looping         : Does the BGS loop?
  #-------------------------------------------------------------------------- 
  def self.bgs_play(name, volume, pitch, position = 0, looping = true)
    return if self.already_playing?(@fmod_bgs, name, position)
    # Now play the new BGS as a stream
    @fmod_bgs = self.play(name, volume, pitch, position, looping, true, $syseting[:bgm_value])
  end
  #--------------------------------------------------------------------------
  # * Stop and Dispose of BGS
  #-------------------------------------------------------------------------- 
  def self.bgs_stop
    self.stop(@fmod_bgs)
    @fmod_bgs = nil
  end
  #--------------------------------------------------------------------------
  # * Return BGS Length in Milliseconds
  #-------------------------------------------------------------------------- 
  def self.bgm_length(sound_file)
    self.get_length(@fmod_bgs)
  end
  #--------------------------------------------------------------------------
  # * Check if a BGS is Playing
  #--------------------------------------------------------------------------  
  def self.bgs_playing?
    return self.playing?(@fmod_bgs)
  end
  #--------------------------------------------------------------------------
  # * Get Current BGS Playing Position
  #-------------------------------------------------------------------------- 
  def self.bgs_position
    return self.get_position(@fmod_bgs)
  end
  #--------------------------------------------------------------------------
  # * Seek to New BGS Playing Position
  #-------------------------------------------------------------------------- 
  def self.bgs_position=(new_pos)
    self.set_position(@fmod_bgs, new_pos)
  end
  #--------------------------------------------------------------------------
  # * Get Current BGS Volume
  #-------------------------------------------------------------------------- 
  def self.bgs_volume
    return self.get_volume(@fmod_bgs)
  end
  #--------------------------------------------------------------------------
  # * Set BGS Volume
  #-------------------------------------------------------------------------- 
  def self.bgs_volume=(volume)
    self.set_volume(@fmod_bgs, volume)
  end
  #--------------------------------------------------------------------------
  # * Set Loop Points
  #     first           : Loop start point in milliseconds
  #     second          : Loop end point in milliseconds
  #     unit            : FMOD_TIMEUNIT for points
  #-------------------------------------------------------------------------- 
  def self.bgs_set_loop_points(first, second, unit = FModEx::FMOD_DEFAULT_UNIT)
    @fmod_bgs = self.set_loop_points(@fmod_bgs, first, second, unit)
  end
  #--------------------------------------------------------------------------
  # * Play SE
  #     name            : Name of the file
  #     volume          : Channel volume
  #     pitch           : Channel frequency
  #-------------------------------------------------------------------------- 
  def self.se_play(name, volume, pitch, position = 0)
    if @fmod_se.size > @fmod.maxChannels
      se = @fmod_se.shift
      self.stop(se)
    end
    # Load SE into memory and play it
    @fmod_se << self.play(name, volume, pitch, position, false, false, $syseting[:se_value])
  end
  #--------------------------------------------------------------------------
  # * Stop and Dispose of all SEs
  #-------------------------------------------------------------------------- 
  def self.se_stop
    for se in @fmod_se
      self.stop(se)
    end
    @fmod_se.clear
  end
  #--------------------------------------------------------------------------
  # * Get Rid of Non-Playing SEs
  #--------------------------------------------------------------------------  
  def self.se_clean
    for se in @fmod_se
      unless self.playing?(se)
        self.stop(se)
        @fmod_se.delete(se)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Check if There's Some SE in SE Array
  #--------------------------------------------------------------------------  
  def self.se_list_empty?
    return @fmod_se.empty?
  end
  #--------------------------------------------------------------------------
  # * Dispose of Everything
  #--------------------------------------------------------------------------  
  def self.dispose
    self.bgm_stop
    self.bgs_stop
    self.se_stop
    @fmod.dispose
  end
  
  def self.sync_vol
    [@fmod_bgm, @fmod_bgs].each do |sound_file|
      if sound_file
        sound_file.base_volume = $syseting[:bgm_value]
        FMod.set_volume(sound_file, sound_file.volume)
      end
    end
  end
end
