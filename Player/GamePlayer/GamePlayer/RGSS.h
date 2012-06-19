#include <Windows.h>
typedef BOOL (*RGSSSetupRTP)(const wchar_t* pIniPath, wchar_t* pErrorMsgBuffer, int iBufferLength);
typedef void (*RGSSSetupFonts)();
typedef void (*RGSSInitialize3)(HMODULE hRgssDll);
typedef int  (*RGSSEval)(const char* pScripts);
typedef void (*RGSSGameMain)(HWND hWnd, const wchar_t* pScriptNames, wchar_t** pRgssadName);
typedef BOOL (*RGSSExInitialize)(HWND hWnd);