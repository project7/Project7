cl *.cpp /c /DUNICODE /EHsc
cl *.obj /Fe../../../Game/Game.exe /link seiran.lib user32.lib kernel32.lib gdi32.lib shlwapi.lib psapi.lib