#include "RGSSBrower.h"
map<HWND,RV> RGSSBrower::hwnd2Func;
set<HWND> RGSSBrower::browers;
RV RGSSBrower::rbcBrower;
int RGSSBrower::pos;
map<HWND,CWebbrowser*> RGSSBrower::hwnd2Web;
map<RV,RGSSBrower::RTL> RGSSBrower::OBJ2RTL;
WNDCLASSEX	RGSSBrower::wc;

void RGSSBrower::InitRuby()
{
	rbcBrower = runtime->rb_define_class("CBrower",runtime->rb_cObject); 
	runtime->rb_define_method(rbcBrower,"initialize",(RV(__cdecl*)(void))dm_initialize,6);
	runtime->rb_define_method(rbcBrower,"dispose",(RV(__cdecl*)(void))dm_dispose,0);
	runtime->rb_define_method(rbcBrower,"x",(RV(__cdecl*)(void))dm_get_x,0);
	runtime->rb_define_method(rbcBrower,"y",(RV(__cdecl*)(void))dm_get_y,0);
	runtime->rb_define_method(rbcBrower,"width",(RV(__cdecl*)(void))dm_get_w,0);
	runtime->rb_define_method(rbcBrower,"height",(RV(__cdecl*)(void))dm_get_h,0);
	runtime->rb_define_method(rbcBrower,"x=",(RV(__cdecl*)(void))dm_set_x,0);
	runtime->rb_define_method(rbcBrower,"y=",(RV(__cdecl*)(void))dm_set_y,0);
	runtime->rb_define_method(rbcBrower,"width=",(RV(__cdecl*)(void))dm_set_w,0);
	runtime->rb_define_method(rbcBrower,"height=",(RV(__cdecl*)(void))dm_set_h,0);

	ZeroMemory(&wc, sizeof(WNDCLASSEX));
	wc.cbSize = sizeof(WNDCLASSEX);
	wc.hInstance = gameplayer->hInstance;
	wc.lpfnWndProc = (WNDPROC)WebProc;
	wc.lpszClassName = L"Web Player";
	RegisterClassEx(&wc);


}

bool RGSSBrower::Install()
{

	//OleInitialize(NULL);
	//pos=SetupWndHook((WNDPROC)WebProc);
	return true;
}

LRESULT RGSSBrower::WebProc(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM lParam)
{
	return DefWindowProc(hWnd,Msg,wParam,lParam);
}
#ifdef HookerTest
extern FILE* LOG;
#endif
RV RGSSBrower::dm_initialize(RV obj,RV url,RV _x,RV _y,RV _w,RV _h,RV callback)
{
	RTL rtl;
#define I2F(v) (runtime->FIX2INT(v))
	rtl.x=I2F(_x);
	rtl.y=I2F(_y);
	rtl.w=I2F(_w);
	rtl.h=I2F(_h);
	rtl.g_hwnd = CreateWindowEx(WS_EX_WINDOWEDGE,L"Web Player",L"Web",WS_CHILD | WS_VISIBLE,rtl.x,rtl.y,rtl.w,rtl.h,gameplayer->g_hWnd,0,gameplayer->hInstance,0);
#undef I2F
	assert(rtl.g_hwnd);

	hwnd2Func.insert(make_pair(rtl.g_hwnd,callback));
	browers.insert(rtl.g_hwnd);	
	OBJ2RTL.insert(make_pair(obj,rtl));
	//lpDisplayHTMLPage(rtl.g_hwnd,L"http://www.baidu.com");
	CWebbrowser *cWeb = new CWebbrowser(rtl.g_hwnd,callback);
	cWeb->OpenWebBrowser();
	VARIANT myurl;
	VariantInit(&myurl);
	myurl.vt = VT_BSTR;
	char * curl = runtime->rb_string_value_ptr(&url);
	
	myurl.bstrVal = _variant_t(curl).bstrVal;//SysAllocString(L"E:\\fux-project\\Game\\a.html");
	cWeb->OpenURL(&myurl);
	hwnd2Web.insert(make_pair(rtl.g_hwnd,cWeb));
	//MessageBox(0,L"CreateWindow Okay",L"Succeed",0);
	return runtime->INT2FIX((int)rtl.g_hwnd);
}

void RGSSBrower::movewindow(RV obj)
{
	RTL rtl = OBJ2RTL.find(obj)->second;
	MoveWindow(rtl.g_hwnd,rtl.x,rtl.y,rtl.w,rtl.h,true);
	CWebbrowser *cWeb = hwnd2Web.find(rtl.g_hwnd)->second;
//	cWeb->(rtl.w,rtl.h);
	
}
RV RGSSBrower::dm_dispose(RV obj)
{
	RTL rtl = OBJ2RTL.find(obj)->second;
	hwnd2Web.find(rtl.g_hwnd)->second->Release();
	DestroyWindow(rtl.g_hwnd);
	browers.erase(rtl.g_hwnd);
	hwnd2Func.erase(rtl.g_hwnd);
	hwnd2Web.erase(rtl.g_hwnd);
	OBJ2RTL.erase(obj);
	return runtime->Qnil;
}
RGSSBrower::RGSSBrower(void)
{
}


RGSSBrower::~RGSSBrower(void)
{
}
