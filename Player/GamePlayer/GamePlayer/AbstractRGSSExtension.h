#pragma once
#include "RGSS3Runtime.h"
#include "GamePlayer.h"

class AbstractRGSSExtension
{
public:
	AbstractRGSSExtension(RGSS3Runtime *_runtime,GamePlayer * _gameplayer);
	~AbstractRGSSExtension(void);
	RGSS3Runtime *runtime;
	GamePlayer * gameplayer;
	void SetupWndHook(WNDPROC proc);
	WNDPROC oldProc;
	LRESULT CallNext(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam);

};

