#include "RGSSWebBrowser.h"

#define RWB RGSSWebBrowser

RWB::RGSSWebBrowser(void)
{
}


RWB::~RGSSWebBrowser(void)
{
}

RV RWB::dm_new_webb(RV obj,RV url,RV ruby_x,RV ruby_y,RV ruby_width,RV ruby_height)
{
	OleInitialize(NULL);
	x = runtime->FIX2INT(ruby_x);
	y = runtime->FIX2INT(ruby_y);
	width = runtime->FIX2INT(ruby_width);
	height = runtime->FIX2INT(ruby_height);
	char* curl = runtime->StringValuePtr(&url);

	g_hwnd = CreateWindowEx(WS_EX_WINDOWEDGE, L"RGSS WebBrower", L"WebBrower", WS_CHILD|WS_VISIBLE,
		x, y, width, height,
		runtime->gamePlayer->g_hWnd, NULL, runtime->gamePlayer->hInstance, 0);
	if (!g_hwnd)
	{
		OleUninitialize();
		return 0;
	}
	IOleObject		*browserObject;
	browserObject = *((IOleObject **)GetWindowLong(g_hwnd, GWL_USERDATA));
	VARIANT			myURL;
	if (!browserObject->QueryInterface( IID_IWebBrowser2, (void**)&webBrowser2))
	{
		VariantInit(&myURL);
		myURL.vt = VT_BSTR;
		wchar_t		*buffer;
		DWORD		size;
		size = MultiByteToWideChar(CP_ACP, 0, curl, -1, 0, 0);
		if (!(buffer = (wchar_t *)GlobalAlloc(GMEM_FIXED, sizeof(wchar_t) * size))) goto badalloc;
		MultiByteToWideChar(CP_ACP, 0, curl, -1, buffer, size);
		myURL.bstrVal = SysAllocString(buffer);
		GlobalFree(buffer);
		if (!myURL.bstrVal)
		{
badalloc:	webBrowser2->Release();
			OleUninitialize();
			return 0;
		}
		webBrowser2->Navigate2(&myURL,0,0,0,0);
		VariantClear(&myURL);
		webBrowser2->Release();
	}
	OleUninitialize();
	return 0;
}
void RWB::InitRuby()
{
	runtime->rb_define_class("WebBrowser",runtime->rb_cObject);
}
LRESULT WINAPI RWB::WebWndProcHook(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam)
{
	if (Msg == WM_CREATE)
	{
		
		
	}
}
bool RWB::Install()
{
	WNDCLASSEX		wc;
	ZeroMemory(&wc, sizeof(WNDCLASSEX));
	wc.cbSize = sizeof(WNDCLASSEX);
	wc.hInstance = runtime->gamePlayer->hInstance;
	wc.lpfnWndProc = WebWndProcHook;
	wc.lpszClassName = L"RGSS WebBrower";
	RegisterClassEx(&wc);
}