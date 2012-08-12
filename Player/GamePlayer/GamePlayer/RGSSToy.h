#pragma once
#include "AbstractRGSSExtension.h"
using namespace std;

class RGSSToy:public AbstractRGSSExtension
{
public:
	static RGSS3Runtime::VALUE mCToy;
	static bool available;

	static int* fps_history;
	static int fps_pos;
	static int fps_count;
	static bool fps_full;

	static int pos;

	RGSSToy(void);
	~RGSSToy(void);
#define RBOOL(val) (val)?runtime->Qtrue:runtime->Qfalse;
	static void InitRuby(){
		fps_history = (int*)malloc(101 * sizeof(int));
		fps_pos = 0;
		fps_full = false;
		fps_count = 0;

		int fps = (*runtime->GetGraphicsPtr(560));
		mCToy = runtime->rb_define_module("CToy");
		runtime->rb_define_module_function(mCToy,"update",(RGSS3Runtime::RubyFunc)dm_update,0);
		runtime->rb_define_module_function(mCToy,"fps_history",(RGSS3Runtime::RubyFunc)dm_fps_history,0);
	}

	static RGSS3Runtime::VALUE RUBYCALL dm_update(RGSS3Runtime::VALUE obj)
	{
		fps_count++;
		if ((fps_count %= 100) == 0)
		{
			DWORD fps;
			fps = (*runtime->GetGraphicsPtr(560));
			if (fps > 0 && fps < 200)
			{
				fps_pos = (fps_pos + 1) % 101;
				fps_history[fps_pos] = fps;

				if (!fps_full && fps_pos == 100)
					fps_full = true;
			}
		}
		return runtime->Qnil;
	}

	static RGSS3Runtime::VALUE RUBYCALL dm_fps_history(RGSS3Runtime::VALUE obj)
	{
		RGSS3Runtime::VALUE ary = runtime->rb_ary_new();
		int i;
		for (i = 1; i < fps_pos; i++)
			runtime->rb_ary_push(ary, runtime->INT2FIX(fps_history[i]));
		if (fps_full)
			for (i = fps_pos; i <= 100; i++)
				runtime->rb_ary_push(ary, runtime->INT2FIX(fps_history[i]));

		return ary;
	}

	static bool Install()
	{
		pos = SetupWndHook((WNDPROC)WndProcHook);
		return true;
	}

	static LRESULT WINAPI WndProcHook(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam)
	{
		//if (Msg == WM_ACTIVATEAPP)
		//	return 0;

		if (Msg == WM_COMMAND || Msg == WM_SYSCOMMAND)
		{
			if (wParam == 0x107D3 || wParam == 0x7D3)
			{
				gameplayer->pRGSSEval("CToy.on_fullscreen rescue nil");
				return 0;
			}
			if (wParam == 0x7D1 || wParam == 0x107D1)
			{
				gameplayer->pRGSSEval("CToy.on_f1 rescue nil");
				return 0;
			}
			if (wParam == 0x7D2 || wParam == 0x107D2)
			{
				gameplayer->pRGSSEval("CToy.on_f2 rescue nil");
				return 0;
			}
		}

		return CallNext(hWnd,Msg,wParam,IParam,pos);
	}
#undef RBOOL
};

RGSS3Runtime::VALUE RGSSToy::mCToy;
bool RGSSToy::available;
int RGSSToy::pos;
int* RGSSToy::fps_history;
int RGSSToy::fps_pos;
bool RGSSToy::fps_full;
int RGSSToy::fps_count;