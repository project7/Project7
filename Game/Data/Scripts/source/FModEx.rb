#==============================================================================
# ** FMOD Ex Audio
#------------------------------------------------------------------------------
#  Script by            :   Hiretsukan (Kevin Gadd)
#                           janus@luminance.org
#  Modified by:         :   RPG/Cowlol (Firas Assad)
#                           ArePeeGee (AIM name)
#  Last Update          :   September 23rd, 2008
#  Version              :   1.5
#------------------------------------------------------------------------------
# A rewrite of the built-in Audio module to extend its functionality
# using the FMOD Ex library (http://www.fmod.org/). In particular,
# it supports several new formats and has the ability to get current
# playing position and seek to a new one, and to set loop points.
# Extensions to Game_System and Scene_Battle makes the memorize BGM/BGS
# event command remember position as well, and map music to resume
# playing from the position it stopped at before a battle, instead
# of starting all over like default RMXP behavior.
#------------------------------------------------------------------------------
# Usage:
#
# You need to copy the file fmodex.dll to your game folder (folder where
# your Game.exe and project file are). I've provided the DLL with the
# demo, and you can also get the latest version from FMOD's official
# website (http://www.fmod.org/index.php/download).
#
# There are three scripts that could be used, the real script is only
# the first one, but the other scripts are provided for convenience:
#
# FModEx 
#           This includes the core functionality and the Audio module
#           rewrite. It's the main script and should be placed on
#           top of all scripts using it. Most people would just add a 
#           new section above the Game_System or Game_Temp section at 
#           the very top of the script editor and paste script there.
# Game_System
#           This script rewrites parts of the Game_System class to 
#           allow memorize_bgm to support remembering position,
#           and to allow the play methods to take an extra parameter
#           specifying position to start playing from.
#           Add it anywhere under the Game_System script section.
#           If you don't need any of these features you don't need this
#           script.
# Other Classes
#           This is really an optional script that modifies the default
#           battle system to memorize map BGM and position instead of
#           starting over after the battle. Add it anywhere under
#           the Scene_Battle classes.
#
# Aside from integration with RMXP's default scripts, you can use
# this script the same way you used the old Audio class You could also
# access the FMod module for more options at a lower level, such as
# setting loop points (FMod.bgm_set_loop_points(first, second) in
# milliseconds) and getting current BGS position (FMod.bgs_position) to
# name a few.
#------------------------------------------------------------------------------
# Compatibility:
#
# This script has different levels of compatibility depending on what
# scripts you use:
#
# FModEx 
#           This script overwrites the Audio module, but since
#           few if any other scripts would do that, it's pretty
#           much compatible with the majority of other scripts
#           without modifications.
# Game_System
#           The following methods of Game_System are redefined:
#             bgm_play, bgm_restore, bgs_play, bgs_restore
#           Any other script that redefines these methods may
#           not work well with this one. Most scripts wouldn't
#           do that, except ones dealing with audio as well.
#           I've marked the areas in the script where I made
#           changes to help you resolve any conflicts
#           The following methods of Game_System are aliased:
#             bgm_memorize, bgs_memorize
#           Other scripts that redefine these methods should
#           be placed above the Game_System script.
# Other Classes
#           The following methods of Scene_Battle are redefined:
#             judge, start_phase5, update_phase5
#           Any other script that redefines these methods may
#           not work well with this one. Custom battle system
#           scripts may do that, so you might consider not
#           including the Other Classes section and just
#           manually add position memorizing functionality.
#           I've marked the areas in the script where I made
#           changes to help you resolve any conflicts
#           The following methods of Game_Temp/Scene_Map are aliased:
#             Game_Temp#initialize, Scene_Map #call_battle
#           Other scripts that redefine these methods should
#           be placed above the Other Classes script.
#
# So in other words, FModEx is the most compatible, followed by
# Game_System, and finally the last and optional Other Classes. 
# If you use a custom battle system you probably shouldn't include
# Other Classes anyway. This isn't an SDK script and I never tested
# it with the SDK. It'll probably work, but refer to SDK documentation
# for more information.
#------------------------------------------------------------------------------
# Version Info:
#   - Version 1.5:
#       - Made the Volume and Pitch paramters to Audio ME/SE playing
#         methods optional. (Thanks panchokoster!)
#       - Script now uses FMOD's software mixer instead of hardware
#         acceleration. This solves issues with certain sound cards.
#       - A message is now displayed when a file isn't found, instead
#         of just throwing the error number.
#       - Added an independent thread to handle updating Audio module,
#         instead of calling it in $game_system#update. This should
#         ensure that it's called in all scenes. (Thanks Zeriab!)
#       - Updated fading calculations to depend on seconds instead
#         of game frames.
#   - Version 1.4:
#       - Fixed a bug where file isn't found if RTP path doesn't end
#         with a backslash (thanks Atoa!).
#       - Added BGM fading in after a ME is done playing to mimic
#         original Audio class behavior, the volume increment when
#         fading is specified by constant Audio::BGM_FADE_IN_INCREMENT.
#       - Several minor bug fixes and minor behavior changes relating
#         to fading out and stopping sounds.
#   - Version 1.3:
#       - Fixed a bug with ME fading out.
#       - Added methods to get BGM and BGS length.
#       - Providing -1 as loop end point to set_loop_points methods
#         makes the sound file's end the loop end point.
#       - Changed implementation of set_loop_points a bit.
#       - Position of BGM/BGS to be played after fading is now
#         remembered instead of starting all over.
#   - Version 1.2:
#       - Fully documented the script, and fixed some bugs.
#       - Completely rewrote Audio module, allowing FMOD to handle
#         BGMs, BGSs, MEs, and SEs except of just BGMs.
#       - Fixed RTP reading to use registry instead of special files..
#   - Version 1.1:
#       - Added position tracking and adjusting.
#       - Added loop point support.
#       - Implemented BGM fading.
#   - Version 1.0:
#       - Hiretsukan (Kevin Gadd)'s initial release.
#------------------------------------------------------------------------------
# Known bugs:
#
#   - MIDI abrupt start when seeking or restoring from position
#   - Found a bug or have some ideas for the next version? Please tell me!
#------------------------------------------------------------------------------
# Terms of Use:
#
#   Use of this script is subject to the permissive BSD-like license below.
#   That basically means you could use it in any way you like as long
#   as you keep the following copyright and license unchanged and available,
#   and don't use name of copyright holder to promote products based on
#   this software. Note, however, that this license only applies to the
#   script, and not to the FMOD library. For more information about FMOD
#   licenses consult FMOD website: http://www.fmod.org/index.php/sales
#   It's free for non-commercial use, and they provide several types
#   of licenses for different types of developers.
#
# Copyright (c) 2005, Kevin Gadd
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * The name of the contributors may not be used to endorse or promote 
#       products derived from this software without specific prior written 
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY Kevin Gadd ''AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Kevin Gadd BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#==============================================================================

#==============================================================================
# ** FModEx
#------------------------------------------------------------------------------
#  FMOD Ex binding by Kevin Gadd (janus@luminance.org)
#==============================================================================

module FModEx
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  # FMOD_INITFLAGS flags
  FMOD_INIT_NORMAL = 0
  # FMOD_RESULT flags
  FMOD_OK = 0
  FMOD_ERR_CHANNEL_STOLEN = 11
  FMOD_ERR_FILE_NOT_FOUND = 23
  FMOD_ERR_INVALID_HANDLE = 36
  # FMOD_MODE flags
  FMOD_DEFAULT = 0
  FMOD_LOOP_OFF = 1
  FMOD_LOOP_NORMAL = 2
  FMOD_LOOP_BIDI = 4
  FMOD_LOOP_BITMASK = 7
  FMOD_2D = 8
  FMOD_3D = 16
  FMOD_HARDWARE = 32
  FMOD_SOFTWARE = 64
  FMOD_CREATESTREAM = 128
  FMOD_CREATESAMPLE = 256
  FMOD_OPENUSER = 512
  FMOD_OPENMEMORY = 1024
  FMOD_OPENRAW = 2048
  FMOD_OPENONLY = 4096
  FMOD_ACCURATETIME = 8192
  FMOD_MPEGSEARCH = 16384
  FMOD_NONBLOCKING = 32768
  FMOD_UNIQUE = 65536
  # The default mode that the script uses
  FMOD_DEFAULT_SOFTWARWE = FMOD_LOOP_OFF | FMOD_2D | FMOD_SOFTWARE
  # FMOD_CHANNELINDEX flags
  FMOD_CHANNEL_FREE = -1
  FMOD_CHANNEL_REUSE = -2
  # FMOD_TIMEUNIT_flags
  FMOD_TIMEUNIT_MS = 1
  FMOD_TIMEUNIT_PCM = 2
  # The default time unit the script uses
  FMOD_DEFAULT_UNIT = FMOD_TIMEUNIT_MS
  # Types supported by FMOD Ex
  FMOD_FILE_TYPES = ['ogg', 'aac', 'wma', 'mp3', 'wav', 'it', 'xm', 'mod', 's3m', 'mid', 'midi']
  
  FMOD_DLSNAME = "Audio\\MIDI.dls"
  #============================================================================
  # ** DLL
  #----------------------------------------------------------------------------
  #  A class that manages importing functions from the DLL
  #============================================================================
  
  class DLL
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #--------------------------------------------------------------------------
    attr_accessor :filename           # DLL file name for instance    
    attr_accessor :functions          # hash of functions imported (by name)
    #--------------------------------------------------------------------------
    # * Object Initialization
    #     filename  : Name of the DLL
    #--------------------------------------------------------------------------
    def initialize(filename = 'fmodex.dll')
      @filename = filename
      @functions = {}
      @handle = 0            # Handle to the DLL
      # Load specified library into the address space of game process
      w32_LL = Win32API.new('kernel32.dll', 'LoadLibrary', 'p', 'l')
      @handle = w32_LL.call(filename)
      # System functions:
      self.import('System_Create', 'p')
      self.import('System_Init', 'llll')
      self.import('System_Close', 'l')
      self.import('System_Release', 'l')
      self.import('System_CreateSound', 'lpllp')
      self.import('System_CreateStream', 'lpllp')
      self.import('System_PlaySound', 'llllp')
      # Sound functions:
      self.import('Sound_Release', 'l')
      self.import('Sound_GetMode', 'lp')
      self.import('Sound_SetMode', 'll')
      self.import('Sound_SetLoopPoints', 'lllll')
      self.import('Sound_GetLength', 'lpl')
      # Channel functions:
      self.import('Channel_Stop', 'l')
      self.import('Channel_IsPlaying', 'lp')
      self.import('Channel_GetPaused', 'lp')
      self.import('Channel_SetPaused', 'll')
      self.import('Channel_GetVolume', 'lp')
      self.import('Channel_SetVolume', 'll')
      self.import('Channel_GetPan', 'lp')
      self.import('Channel_SetPan', 'll')
      self.import('Channel_GetFrequency', 'lp')
      self.import('Channel_SetFrequency', 'll')
      self.import('Channel_GetPosition', 'lpl')
      self.import('Channel_SetPosition', 'lll')
    end
    #--------------------------------------------------------------------------
    # * Create a Win32API Object And Add it to Hashtable
    #     name      : Function name
    #     args      : Argument types (p = pointer, l = int, v = void)
    #     returnType: Type of value returned by function
    #--------------------------------------------------------------------------
    def import(name, args = '', returnType = 'l')
      @functions[name] = Win32API.new(@filename, 'FMOD_' + name, args, returnType)
    end
    #--------------------------------------------------------------------------
    # * Get Function by Name
    #     key       : Function name
    #--------------------------------------------------------------------------
    def [](key)
      return @functions[key]
    end
    #--------------------------------------------------------------------------
    # * Call a Function With Passed Arguments
    #     name      : Function name
    #     args      : Argument to function
    #--------------------------------------------------------------------------
    def invoke(name, *args)
      fn = @functions[name]
      raise "function not imported: #{name}" if fn.nil?
      result = fn.call(*args)
      unless result == FMOD_OK or result == FMOD_ERR_CHANNEL_STOLEN or
        result == FMOD_ERR_FILE_NOT_FOUND
        raise "FMOD Ex returned error #{result}"
      end
      return result
    end
    #--------------------------------------------------------------------------
    # * Store Float as Binary Int Because Floats Can't be Passed Directly
    #     f         : Float to convert
    #--------------------------------------------------------------------------
    def convertFloat(f)
      # First pack the float in a string as a native binary float
      temp = [f].pack('f')
      # Then unpack the native binary float as an integer
      return unpackInt(temp)
    end
    #--------------------------------------------------------------------------
    # * Unpack Binary Data to Integer
    #     s         : String containing binary data
    #--------------------------------------------------------------------------
    def unpackInt(s)
      return s.unpack('l')[0]
    end
    #--------------------------------------------------------------------------
    # * Unpack Binary Data to Float
    #     s         : String containing binary data
    #--------------------------------------------------------------------------
    def unpackFloat(s)
      return s.unpack('f')[0]
    end
    #--------------------------------------------------------------------------
    # * Unpack Binary Data to Boolean
    #     s         : String containing binary data
    #--------------------------------------------------------------------------
    def unpackBool(s)
      return s.unpack('l')[0] != 0
    end
  end

  #============================================================================
  # ** System
  #----------------------------------------------------------------------------
  #  A class that manages an instance of FMOD::System
  #============================================================================
  
  class System
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #-------------------------------------------------------------------------- 
    attr_accessor :fmod               # Instance of DLL class (fmodex.dll)
    attr_accessor :handle             # Handle (pointer) to System object
    attr_accessor :maxChannels        # Maximum number of channels
    #--------------------------------------------------------------------------
    # * Object Initialization
    #     fmod            : An instance of DLL class
    #     maxChannels     : Maximum number of used channels
    #     flags           : FMOD_INITFLAGS
    #     extraDriverData : Driver specific data
    #--------------------------------------------------------------------------
    def initialize(theDLL, maxChannels = 32, flags = FMOD_INIT_NORMAL, extraDriverData = 0)
      @fmod = theDLL
      @maxChannels = maxChannels
      # Create and initialize FMOD::System
      temp = 0.chr * 4
      @fmod.invoke('System_Create', temp)
      @handle = @fmod.unpackInt(temp)
      @fmod.invoke('System_Init', @handle, maxChannels, flags, extraDriverData)
    end
    #--------------------------------------------------------------------------
    # * Create FMOD::Sound (fully loaded into memory by default)
    #     filename        : Name of file to open
    #     mode            : FMOD_MODE flags
    #--------------------------------------------------------------------------
    def createSound(filename, mode = FMOD_DEFAULT_SOFTWARWE)
      # Create sound and return it
      temp = 0.chr * 4
      result = @fmod.invoke('System_CreateSound', @handle, filename, mode, 0, temp)
      raise "File not found: \"#{filename}\"" if result == FMOD_ERR_FILE_NOT_FOUND
      newSound = Sound.new(self, @fmod.unpackInt(temp))
      return newSound
    end
    #--------------------------------------------------------------------------
    # * Create Streamed FMOD::Sound (chunks loaded on demand)
    #     filename        : Name of file to open
    #     mode            : FMOD_MODE flags
    #--------------------------------------------------------------------------
    def createStream(filename, mode = FMOD_DEFAULT_SOFTWARWE)
      # Create sound and return it
      temp = 0.chr * 4
      if filename[/\.midi?$/i] && File.exist?(FModEx::FMOD_DLSNAME)
        infoex = "\x88\0\0\0".force_encoding("ASCII-8BIT") + ("\0".force_encoding("ASCII-8BIT") * 52) + [FModEx::FMOD_DLSNAME.dup].pack("p").force_encoding("ASCII-8BIT") + ("\0".force_encoding("ASCII-8BIT") * 76)
        info = [infoex].pack("p").unpack('l')[0]
        result = @fmod.invoke('System_CreateStream', @handle, filename, mode, info, temp)
      else
        result = @fmod.invoke('System_CreateStream', @handle, filename, mode, 0, temp)
      end
      raise "File not found: \"#{filename}\"" if result == FMOD_ERR_FILE_NOT_FOUND
      newSound = Sound.new(self, @fmod.unpackInt(temp))
      return newSound
    end
    #--------------------------------------------------------------------------
    # * Close And Release System
    #--------------------------------------------------------------------------
    def dispose
      if (@handle > 0)
        @fmod.invoke('System_Close', @handle)
        @fmod.invoke('System_Release', @handle)
        @handle = 0
      end
      @fmod = nil
    end
  end

  #============================================================================
  # ** Sound
  #----------------------------------------------------------------------------
  #  A class that manages an instance of FMOD::Sound
  #============================================================================
  
  class Sound
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #-------------------------------------------------------------------------- 
    attr_accessor :system             # System that created this Sound
    attr_accessor :fmod               # Instance of DLL class (fmodex.dll)
    attr_accessor :handle             # Handle (pointer) to Sound object
    #--------------------------------------------------------------------------
    # * Object Initialization
    #     theSystem       : The System that created this Sound object
    #     handle          : Handle to the FMOD::Sound object
    #--------------------------------------------------------------------------
    def initialize(theSystem, theHandle)
      @system = theSystem
      @fmod = theSystem.fmod
      @handle = theHandle
    end
    #--------------------------------------------------------------------------
    # * Play Sound
    #     paused          : Start paused?
    #     channel         : Channel allocated to sound (nil for automatic)
    #--------------------------------------------------------------------------
    def play(paused = false, channel = nil)
      # If channel wasn't specified, let FMOD pick a free one,
      # otherwise use the passed channel (id from 0 to maxChannels)
      unless channel
        temp = 0.chr * 4
      else
        temp = [channel].pack('l')
      end
      @fmod.invoke('System_PlaySound', @system.handle, 
                (channel == nil) ? FMOD_CHANNEL_FREE : FMOD_CHANNEL_REUSE, 
                @handle,
                (paused == true) ? 1 : 0, 
                temp)
      theChannel = @fmod.unpackInt(temp)
      # Create a Channel object based on returned channel
      newChannel = Channel.new(self, theChannel)
      return newChannel
    end
    #--------------------------------------------------------------------------
    # * Get FMOD_MODE Bits
    #--------------------------------------------------------------------------
    def mode
      temp = 0.chr * 4
      @fmod.invoke('Sound_GetMode', @handle, temp)
      return @fmod.unpackInt(temp)
    end
    #--------------------------------------------------------------------------
    # * Set FMOD_MODE Bits
    #--------------------------------------------------------------------------
    def mode=(newMode)
      @fmod.invoke('Sound_SetMode', @handle, newMode)
    end
    #--------------------------------------------------------------------------
    # * Get FMOD_LOOP_MODE
    #--------------------------------------------------------------------------  
    def loopMode
      temp = 0.chr * 4
      @fmod.invoke('Sound_GetMode', @handle, temp)
      return @fmod.unpackInt(temp) & FMOD_LOOP_BITMASK
    end
    #--------------------------------------------------------------------------
    # * Set FMOD_LOOP_MODE
    #--------------------------------------------------------------------------  
    def loopMode=(newMode)
      @fmod.invoke('Sound_SetMode', @handle, (self.mode & ~FMOD_LOOP_BITMASK) | newMode)
    end
    #--------------------------------------------------------------------------
    # * Return Sound Length
    #-------------------------------------------------------------------------- 
    def length(unit = FMOD_DEFAULT_UNIT)
      temp = 0.chr * 4
      @fmod.invoke('Sound_GetLength', @handle, temp, unit)
      return @fmod.unpackInt(temp)
    end
    #--------------------------------------------------------------------------
    # * Set Loop Points
    #     first           : Loop start point in milliseconds
    #     second          : Loop end point in milliseconds
    #     unit            : FMOD_TIMEUNIT for points
    #--------------------------------------------------------------------------    
    def setLoopPoints(first, second, unit = FMOD_DEFAULT_UNIT)
      @fmod.invoke('Sound_SetLoopPoints', @handle, first, unit, second, unit)
    end
    #--------------------------------------------------------------------------
    # * Release Sound
    #-------------------------------------------------------------------------- 
    def dispose
      if (@handle > 0)
        @fmod.invoke('Sound_Release', @handle)
        @handle = 0
      end
      @fmod = nil
      @system = nil
    end
  end

  #============================================================================
  # ** Channel
  #----------------------------------------------------------------------------
  #  A class that represents an FMOD::Channel
  #============================================================================
  
  class Channel
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #-------------------------------------------------------------------------- 
    attr_accessor :system             # System that created the Sound
    attr_accessor :sound              # Sound using the Channel
    attr_accessor :fmod               # Instance of DLL class (fmodex.dll)
    attr_accessor :handle             # Handle (pointer) to Sound object
    #--------------------------------------------------------------------------
    # * Object Initialization
    #     theSound        : The Sound using this Channel object
    #     handle          : Handle to the FMOD::Channel object
    #--------------------------------------------------------------------------
    def initialize(theSound, theHandle)
      @sound = theSound
      @system = theSound.system
      @fmod = theSound.system.fmod
      @handle = theHandle
    end
    #--------------------------------------------------------------------------
    # * Stop Channel and Make it Available for Other Sounds
    #--------------------------------------------------------------------------
    def stop
      @fmod.invoke('Channel_Stop', @handle)
    end
    #--------------------------------------------------------------------------
    # * Is the Channel Handle Valid?
    #--------------------------------------------------------------------------
    def valid?
      temp = 0.chr * 4
      begin
        result = @fmod.invoke('Channel_IsPlaying', @handle, temp)
      rescue
        if (result == FMOD_ERR_INVALID_HANDLE)
          return false
        else
          raise
        end
      end
      # If we get here then it's valid
      return true
    end
    #--------------------------------------------------------------------------
    # * Is the Channel Playing?
    #--------------------------------------------------------------------------
    def playing?
      temp = 0.chr * 4
      @fmod.invoke('Channel_IsPlaying', @handle, temp)
      return @fmod.unpackBool(temp)
    end
    #--------------------------------------------------------------------------
    # * Get Channel Volume Level (0.0 -> 1.0)
    #--------------------------------------------------------------------------
    def volume
      temp = 0.chr * 4
      @fmod.invoke('Channel_GetVolume', @handle, temp)
      return @fmod.unpackFloat(temp)
    end
    #--------------------------------------------------------------------------
    # * Set Channel Volume Level (0.0 -> 1.0)
    #--------------------------------------------------------------------------
    def volume=(newVolume)
      @fmod.invoke('Channel_SetVolume', @handle, @fmod.convertFloat(newVolume))
    end
    #--------------------------------------------------------------------------
    # * Get Channel Pan Position (-1.0 -> 1.0)
    #--------------------------------------------------------------------------
    def pan
      temp = 0.chr * 4
      @fmod.invoke('Channel_GetPan', @handle, temp)
      return @fmod.unpackFloat(temp)
    end
    #--------------------------------------------------------------------------
    # * Set Channel Pan Position (-1.0 -> 1.0)
    #--------------------------------------------------------------------------
    def pan=(newPan)
      @fmod.invoke('Channel_SetPan', @handle, @fmod.convertFloat(newPan))
    end
    #--------------------------------------------------------------------------
    # * Get Channel Frequency in HZ (Speed/Pitch)
    #--------------------------------------------------------------------------
    def frequency
      temp = 0.chr * 4
      @fmod.invoke('Channel_GetFrequency', @handle, temp)
      return @fmod.unpackFloat(temp)
    end
    #--------------------------------------------------------------------------
    # * Set Channel Frequency in HZ (Speed/Pitch)
    #--------------------------------------------------------------------------
    def frequency=(newFrequency)
      @fmod.invoke('Channel_SetFrequency', @handle, @fmod.convertFloat(newFrequency))
    end
    #--------------------------------------------------------------------------
    # * Is Channel Paused?
    #--------------------------------------------------------------------------
    def paused
      temp = 0.chr * 4
      @fmod.invoke('Channel_GetPaused', @handle, temp)
      return @fmod.unpackBool(temp)
    end
    #--------------------------------------------------------------------------
    # * Pause Channel
    #--------------------------------------------------------------------------
    def paused=(newPaused)
      @fmod.invoke('Channel_SetPaused', @handle, (newPaused == true) ? 1 : 0)
    end
    #--------------------------------------------------------------------------
    # * Get Current Playback Position
    #     unit            : FMOD_TIMEUNIT to return position in
    #--------------------------------------------------------------------------   
    def position(unit = FMOD_DEFAULT_UNIT)
      temp = 0.chr * 4
      @fmod.invoke('Channel_GetPosition', @handle, temp, unit)
      return @fmod.unpackInt(temp)
    end
    #--------------------------------------------------------------------------
    # * Set Current Playback Position
    #     newPosition     : New playback position
    #     unit            : FMOD_TIMEUNIT to use when setting position
    #--------------------------------------------------------------------------    
    def position=(newPosition, unit = FMOD_DEFAULT_UNIT)
      @fmod.invoke('Channel_SetPosition', @handle, newPosition, unit)
    end
    #--------------------------------------------------------------------------
    # * Dispose of Channel
    #--------------------------------------------------------------------------  
    def dispose
      @handle = 0
      @sound = nil
      @system = nil
      @fmod = nil
    end
  end
  
end

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
    #--------------------------------------------------------------------------
    # * Object Initialization
    #--------------------------------------------------------------------------
    def initialize(name, sound, channel, volume, pitch, looping, streaming, length)
      @name = name
      @sound = sound
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
  def self.play(name, volume, pitch, position, looping, streaming)
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
    sound_file.channel.volume = volume / 100.0
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
    sound_file.channel.volume = volume / 100.0
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
    @fmod_bgs = self.play(name, volume, pitch, position, looping, true)
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
    @fmod_se << self.play(name, volume, pitch, position, false, false)
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
end

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
end

# Create an endless loop to update Audio module
Thread.new do
  loop do
    sleep 0.2
    Audio.update
  end
end
