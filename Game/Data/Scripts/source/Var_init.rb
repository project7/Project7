$team_set = []
$pl_actor = nil
$sel_body = nil
$random_center = Random.new(65535)

begin
  Dir["*.log"].each{|i| File.delete((Dir.getwd + '/'+i))}
rescue
end

=begin
  # constructs of virtual key codes
  VK_BACK         = 0x08
  VK_TAB          = 0x09
  
  # 0x0A - 0x0B : reserved
  
  VK_CLEAR        = 0x0C
  VK_RETURN       = 0x0D
  
  VK_SHIFT        = 0x10
  VK_CONTROL      = 0x11
  VK_MENU         = 0x12
  VK_PAUSE        = 0x13
  VK_CAPITAL      = 0x14
  
  VK_KANA         = 0x15
  VK_HANGEUL      = 0x15  # old name - should be here for compatibility
  VK_HANGUL       = 0x15
  VK_JUNJA        = 0x17
  VK_FINAL        = 0x18
  VK_HANJA        = 0x19
  VK_KANJI        = 0x19
  
  VK_ESCAPE       = 0x1B
  
  VK_CONVERT      = 0x1C
  VK_NONCONVERT   = 0x1D
  VK_ACCEPT       = 0x1E
  VK_MODECHANGE   = 0x1F
  
  VK_SPACE        = 0x20
  VK_PRIOR        = 0x21
  VK_NEXT         = 0x22
  VK_END          = 0x23
  VK_HOME         = 0x24
  VK_LEFT         = 0x25
  VK_UP           = 0x26
  VK_RIGHT        = 0x27
  VK_DOWN         = 0x28
  VK_SELECT       = 0x29
  VK_PRINT        = 0x2A
  VK_EXECUTE      = 0x2B
  VK_SNAPSHOT     = 0x2C
  VK_INSERT       = 0x2D
  VK_DELETE       = 0x2E
  VK_HELP         = 0x2F
  
  # VK_0 - VK_9 are the same as ASCII '0' - '9' (0x30 - 0x39)
  # 0x40 : unassigned
  # VK_A - VK_Z are the same as ASCII 'A' - 'Z' (0x41 - 0x5A)
  
  VK_0            = 0x30
  VK_1            = 0x31
  VK_2            = 0x32
  VK_3            = 0x33
  VK_4            = 0x34
  VK_5            = 0x35
  VK_6            = 0x36
  VK_7            = 0x37
  VK_8            = 0x38
  VK_9            = 0x39
  
  VK_A            = 0x41
  VK_B            = 0x42
  VK_C            = 0x43
  VK_D            = 0x44
  VK_E            = 0x45
  VK_F            = 0x46
  VK_G            = 0x47
  VK_H            = 0x48
  VK_I            = 0x49
  VK_J            = 0x4A
  VK_K            = 0x4B
  VK_L            = 0x4C
  VK_M            = 0x4D
  VK_N            = 0x4E
  VK_O            = 0x4F
  VK_P            = 0x50
  VK_Q            = 0x51
  VK_R            = 0x52
  VK_S            = 0x53
  VK_T            = 0x54
  VK_U            = 0x55
  VK_V            = 0x56
  VK_W            = 0x57
  VK_X            = 0x58
  VK_Y            = 0x59
  VK_Z            = 0x5A
  
  VK_LWIN         = 0x5B
  VK_RWIN         = 0x5C
  VK_APPS         = 0x5D
  
  # 0x5E : reserved
  
  VK_SLEEP        = 0x5F
  
  VK_NUMPAD0      = 0x60
  VK_NUMPAD1      = 0x61
  VK_NUMPAD2      = 0x62
  VK_NUMPAD3      = 0x63
  VK_NUMPAD4      = 0x64
  VK_NUMPAD5      = 0x65
  VK_NUMPAD6      = 0x66
  VK_NUMPAD7      = 0x67
  VK_NUMPAD8      = 0x68
  VK_NUMPAD9      = 0x69
  VK_MULTIPLY     = 0x6A
  VK_ADD          = 0x6B
  VK_SEPARATOR    = 0x6C
  VK_SUBTRACT     = 0x6D
  VK_DECIMAL      = 0x6E
  VK_DIVIDE       = 0x6F
  VK_F1           = 0x70
  VK_F2           = 0x71
  VK_F3           = 0x72
  VK_F4           = 0x73
  VK_F5           = 0x74
  VK_F6           = 0x75
  VK_F7           = 0x76
  VK_F8           = 0x77
  VK_F9           = 0x78
  VK_F10          = 0x79
  VK_F11          = 0x7A
  VK_F12          = 0x7B
  VK_F13          = 0x7C
  VK_F14          = 0x7D
  VK_F15          = 0x7E
  VK_F16          = 0x7F
  VK_F17          = 0x80
  VK_F18          = 0x81
  VK_F19          = 0x82
  VK_F20          = 0x83
  VK_F21          = 0x84
  VK_F22          = 0x85
  VK_F23          = 0x86
  VK_F24          = 0x87
  
  # 0x88 - 0x8F : unassigned
  
  VK_NUMLOCK      = 0x90
  VK_SCROLL       = 0x91
  
  # NEC PC-9800 kbd definitions
  VK_OEM_NEC_EQUAL= 0x92   # '=' key on numpad
  
  # Fujitsu/OASYS kbd definitions
  VK_OEM_FJ_JISHO = 0x92   # 'Dictionary' key
  VK_OEM_FJ_MASSHOU = 0x93   # 'Unregister word' key
  VK_OEM_FJ_TOUROKU = 0x94   # 'Register word' key
  VK_OEM_FJ_LOYA  = 0x95   # 'Left OYAYUBI' key
  VK_OEM_FJ_ROYA  = 0x96   # 'Right OYAYUBI' key
  
  # 0x97 - 0x9F : unassigned
  
  # VK_L* & VK_R* - left and right Alt, Ctrl and Shift virtual keys.
  # Used only as parameters to GetAsyncKeyState() and GetKeyState().
  # No other API or message will distinguish left and right keys in this way.
  VK_LSHIFT       = 0xA0
  VK_RSHIFT       = 0xA1
  VK_LCONTROL     = 0xA2
  VK_RCONTROL     = 0xA3
  VK_LMENU        = 0xA4
  VK_RMENU        = 0xA5
=end
