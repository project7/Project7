#==============================================================================
# ** Audio
#------------------------------------------------------------------------------
#  The module that carries out music and sound processing.
#==============================================================================

module Audio
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  BGM_FADE_IN_INCREMENT = 5     # BGM volume incremented 0.2 seconds
  #--------------------------------------------------------------------------
  # * Instance Variables
  #--------------------------------------------------------------------------
  @bgm_fading_out = false       # BGM started fading out
  @bgm_fade_decrement = 0.0     # BGM volume decremented each update
  @bgs_fading_out = false       # BGS started fading out
  @bgs_fade_decrement = 0.0     # BGS volume decremented each update
  @me_fading_out = false        # ME started fading out
  @me_fade_decrement = 0.0      # ME volume decremented each update
  @me_playing = false           # Is some ME playing?
  @playing_bgm = nil            # BGM currently being played
  @next_bgm = nil               # The BGM to be played after fading out
  @next_bgm_position = 0        # Starting position of next bgm
  @next_bgs = nil               # The BGS to be played after fading out
  @next_bgs_position = 0        # Starting position of next bgm
  @next_me = nil                # The ME to be played after fading
  #--------------------------------------------------------------------------
  # * Starts BGM Playback
  #     name            : Name of the file
  #     volume          : Channel volume
  #     pitch           : Channel frequency
  #     position        : Starting position in milliseconds
  #-------------------------------------------------------------------------- 
  def Audio.bgm_play(filename, volume = 100, pitch = 100, position = 0, fade_in = false)
    if @bgm_fading_out and !fade_in
      @next_bgm = RPG::AudioFile.new(filename, volume, pitch)
      @next_bgm_position = position
      return
    end
    start_volume = volume
    if fade_in
      @bgm_target_volume = volume unless @bgm_fading_in
      @bgm_fading_in = true
      start_volume = 0
    end
    @bgm_fading_out = false
    # If a ME is playing we wait until it's over before playing BGM
    unless @me_playing
      FMod::bgm_play(filename, start_volume, pitch, position)
    end
    @playing_bgm = RPG::AudioFile.new(filename, volume, pitch)
    @memorized_bgm = @playing_bgm
    @memorized_bgm_position = position
  end
  #--------------------------------------------------------------------------
  # * Stops BGM Playback
  #-------------------------------------------------------------------------- 
  def Audio.bgm_stop
    @memorized_bgm = nil
    @playing_bgm = nil
    @bgm_fading_in = false
    @bgm_fading_out = false
    # MEs are internally BGMs, but are stopped with me_stop instead
    if @me_playing
      return
    end
    FMod::bgm_stop
  end
  def Audio.bgm_pos
    FMod::bgm_position
  end
  def Audio.bgs_pos
    FMod::bgs_position
  end
  #--------------------------------------------------------------------------
  # * Starts BGM fadeout.
  #     time            : Length of the fadeout in milliseconds.
  #-------------------------------------------------------------------------- 
  def Audio.bgm_fade(time)
    return if @me_playing or !FMod::bgm_playing?
    @bgm_fading_out = true
    time = time / 1000
    @bgm_fade_decrement = FMod::bgm_volume / (time * 5)
  end
  #--------------------------------------------------------------------------
  # * Starts BGS Playback
  #     name            : Name of the file
  #     volume          : Channel volume
  #     pitch           : Channel frequency
  #     position        : Starting position in milliseconds
  #-------------------------------------------------------------------------- 
  def Audio.bgs_play(filename, volume = 100, pitch = 100, position = 0)
    if @bgs_fading_out
      @next_bgs = RPG::AudioFile.new(filename, volume, pitch)
      @next_bgs_position = position
      return
    end
    FMod::bgs_play(filename, volume, pitch, position)
  end
  #--------------------------------------------------------------------------
  # * Stops BGS Playback
  #-------------------------------------------------------------------------- 
  def Audio.bgs_stop
    FMod::bgs_stop
    @bgs_fading_out = false
  end
  #--------------------------------------------------------------------------
  # * Starts BGS fadeout.
  #     time            : Length of the fadeout in milliseconds.
  #-------------------------------------------------------------------------- 
  def Audio.bgs_fade(time)
    return unless FMod::bgs_playing?
    @bgs_fading_out = true
    time = time / 1000
    @bgs_fade_decrement = FMod::bgs_volume / (time * 5)
  end
  #--------------------------------------------------------------------------
  # * Starts ME Playback
  #     name            : Name of the file
  #     volume          : Channel volume
  #     pitch           : Channel frequency
  #-------------------------------------------------------------------------- 
  def Audio.me_play(filename, volume = 100, pitch = 100)
    if @me_fading_out
      @next_me = RPG::AudioFile.new(filename, volume, pitch)
      return
    end
    if @bgm_fading_out
      self.bgm_stop
    end
    # Memorize playing bgm
    if @playing_bgm and !@me_playing
      bgm = @playing_bgm
      @playing_bgm = RPG::AudioFile.new(bgm.name, FMod::bgm_volume, bgm.pitch)
      @memorized_bgm = @playing_bgm
      @memorized_bgm_position = FMod::bgm_position
    end
    @me_playing = true
    FMod::bgm_play(filename, volume, pitch, 0, false)
  end
  #--------------------------------------------------------------------------
  # * Stops ME Playback
  #-------------------------------------------------------------------------- 
  def Audio.me_stop
    return unless @me_playing
    @me_playing = false
    @me_fading_out = false
    # Play memorized bgm, fading in
    if @memorized_bgm and !@bgm_fading_out
      bgm = @memorized_bgm
      self.bgm_play(bgm.name, bgm.volume, bgm.pitch, @memorized_bgm_position, true)
    else
      self.bgm_stop
    end
  end
  #--------------------------------------------------------------------------
  # * Starts ME fadeout.
  #     time            : Length of the fadeout in milliseconds.
  #-------------------------------------------------------------------------- 
  def Audio.me_fade(time)
    return unless FMod::bgm_playing?
    @me_fading_out = true
    time = time / 1000
    @bgm_fade_decrement = FMod::bgm_volume / (time * 5)
  end
  #--------------------------------------------------------------------------
  # * Starts SE Playback
  #     name            : Name of the file
  #     volume          : Channel volume
  #     pitch           : Channel frequency
  #-------------------------------------------------------------------------- 
  def Audio.se_play(filename, volume = 100, pitch = 100) 
    FMod::se_play(filename, volume, pitch)
  end
  #--------------------------------------------------------------------------
  # * Stops SE Playback
  #-------------------------------------------------------------------------- 
  def Audio.se_stop 
    FMod::se_stop
  end
  #--------------------------------------------------------------------------
  # * Update ME Playback, SE Disposal and Fading, Called Each Frame
  #-------------------------------------------------------------------------- 
  def Audio.update
    # Stop ME when it's over (and continue playing BGM)
    if @me_playing
      unless FMod::bgm_playing?
        self.me_stop
      end
    end
    # Remove any finished SEs
    unless FMod::se_list_empty?
      FMod::se_clean
    end
    if @bgm_fading_in
      # Stop fading when target is reached, otherwise increase volume
      if FMod::bgm_volume >= @bgm_target_volume
        @bgm_fading_in = false
      else
        current_volume = FMod::bgm_volume + BGM_FADE_IN_INCREMENT
        FMod::bgm_volume = current_volume
      end
    end
    if FMod::bgm_playing? and @bgm_fading_out and 
        !@me_playing
      if FMod::bgm_volume <= 0
        @bgm_fading_out = false
        self.bgm_stop
        # If another BGM played while fading out, play it (most recent)
        if @next_bgm
          self.bgm_play(@next_bgm.name, @next_bgm.volume,
                        @next_bgm.pitch, @next_bgm_position)
          @next_bgm = nil
        end
      else
        current_volume = FMod::bgm_volume - @bgm_fade_decrement
        FMod::bgm_volume = current_volume
      end
    end
    if FMod::bgs_playing? and @bgs_fading_out
      if FMod::bgs_volume <= 0
        @bgs_fading_out = false
        self.bgs_stop
        # If another BGS played while fading out, play it (most recent)
        if @next_bgs
          self.bgs_play(@next_bgs.name, @next_bgs.volume, 
                        @next_bgs.pitch, @next_bgs_position)
          @next_bgs = nil
        end
      else
        current_volume = FMod::bgs_volume - @bgs_fade_decrement
        FMod::bgs_volume = current_volume
      end
    end
    if FMod::bgm_playing? and @me_fading_out
      if FMod::bgm_volume <= 0
        # If another ME played while fading out, play it (most recent)
        if @next_me
          self.me_play(@next_me.name, @next_me.volume, @next_me.pitch)
          @next_me = nil
        else
          @me_fading_out = false
          self.me_stop
        end
      else
        current_volume = FMod::bgm_volume - @bgm_fade_decrement
        FMod::bgm_volume = current_volume
      end
    end
  end
  
  def self.sync_vol
    FMod.sync_vol
  end
end

# Create an endless loop to update Audio module
Thread.new do
  loop do
    sleep 0.2
    Audio.update
  end
end
