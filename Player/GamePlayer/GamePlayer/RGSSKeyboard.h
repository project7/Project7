#pragma once
#include "AbstractRGSSExtension.h"

class RGSSKeyboard:public AbstractRGSSExtension
{
public:
	RGSSKeyboard();
	~RGSSKeyboard(void);
	static RGSS3Runtime::VALUE RUBYCALL dm_keydown(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE vKey);
	static RGSS3Runtime::VALUE RUBYCALL dm_keyup(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE vKey);
	static RGSS3Runtime::VALUE RUBYCALL dm_keypress(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE vKey);
	static RGSS3Runtime::VALUE RUBYCALL dm_keyupdate(RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_getall(RGSS3Runtime::VALUE obj);
	RGSS3Runtime::VALUE mCInput;

};
extern RGSSKeyboard *cRGSSKeyboard;
LRESULT WINAPI KeyboardWndProcHook(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam);
