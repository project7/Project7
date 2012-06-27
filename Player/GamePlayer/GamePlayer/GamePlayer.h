#pragma once
#include <windows.h>
#include "RGSS.h"
#include <stdio.h>
static class GamePlayer
{
public:
	GamePlayer(HINSTANCE _hInstance, HINSTANCE _hPrevInstance, LPSTR _lpCmdLine, int _nCmdShow,int width=800,int height=600);
	~GamePlayer(void);
	HWND __rgssx_get_hwnd();
	static void ShowErrorMsg(HWND hWnd, const wchar_t* szTitle, const wchar_t* szFormat, ...);
	HWND StartWindow();
	bool InitRGSS();
	void RunGame();
	void ___exit();
	WNDPROC HookWndProc(WNDPROC newProc);
public:
	wchar_t* pWndClassName;
	wchar_t* pDefaultLibrary;
	wchar_t* pDefaultTitle;
	wchar_t* pDefaultScripts;
	int nScreenWidth;
	int nScreenHeight;
	int nEvalErrorCode;
	HWND  g_hWnd;
	HINSTANCE hInstance; HINSTANCE hPrevInstance; LPSTR lpCmdLine; int nCmdShow;
	wchar_t szAppPath[MAX_PATH], szIniPath[MAX_PATH], szRgssadPath[MAX_PATH];
	wchar_t szLibrary[MAX_PATH], szTitle[MAX_PATH], szScripts[MAX_PATH];
	wchar_t* pRgssad;
	HMODULE hRgssCore;
	RGSSSetupRTP  pRGSSSetupRTP;//  = NULL;
	RGSSSetupFonts  pRGSSSetupFonts;//  = NULL;
	RGSSInitialize3  pRGSSInitialize3;// = NULL;
	RGSSEval   pRGSSEval;//   = NULL;
	RGSSGameMain  pRGSSGameMain;//  = NULL;
	RGSSExInitialize pRGSSExInitialize;// = (RGSSExInitialize)::GetProcAddress(hRgssCore, "RGSSExInitialize");
};

