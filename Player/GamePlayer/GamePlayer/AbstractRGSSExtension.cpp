#include "AbstractRGSSExtension.h"


AbstractRGSSExtension::AbstractRGSSExtension(RGSS3Runtime *_runtime,GamePlayer * _gameplayer)
{
	runtime=_runtime;
	gameplayer =_gameplayer;
}


AbstractRGSSExtension::~AbstractRGSSExtension(void)
{
}

void AbstractRGSSExtension::SetupWndHook(WNDPROC proc)
{
	oldProc=gameplayer->HookWndProc(proc);
}
LRESULT AbstractRGSSExtension::CallNext(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam)
{
	return CallWindowProc(oldProc,hWnd,Msg,wParam,IParam);
}