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