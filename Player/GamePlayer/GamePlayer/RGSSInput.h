#pragma once
#include "AbstractRGSSExtension.h"
class RGSSInput:public AbstractRGSSExtension
{
public:
	RGSSInput(void);//(RGSS3Runtime *_runtime,GamePlayer * _gameplayer):AbstractRGSSExtension(_runtime, _gameplayer){};
	~RGSSInput(void);
	static bool Install();
	static RGSS3Runtime::VALUE RUBYCALL dm_keydown(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE vKey);
	static RGSS3Runtime::VALUE RUBYCALL dm_keyup(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE vKey);
	static RGSS3Runtime::VALUE RUBYCALL dm_keypress(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE vKey);
	static RGSS3Runtime::VALUE RUBYCALL dm_keyupdate(RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_getall(RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE mCInput;
	static LRESULT WINAPI KeyboardWndProcHook(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam);
	static map<long,bool> keydown;
	static map<long,bool> keyup;
	static map<long,bool> keypress;
	static int pos;
	static void InitRuby();
};

