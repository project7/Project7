#include "RGSSBrower.h"
map<HWND,RV> RGSSBrower::hwnd2Func;
set<HWND> RGSSBrower::browers;
HMODULE RGSSBrower::hHtmlLite;
RV RGSSBrower::rbcBrower;
int RGSSBrower::pos;
map<HWND,CWebbrowser*> RGSSBrower::hwnd2Web;
map<RV,RGSSBrower::RTL> RGSSBrower::OBJ2RTL;
WNDCLASSEX	RGSSBrower::wc;
/*RGSSBrower::EmbedBrowserObjectPtr		*RGSSBrower::lpEmbedBrowserObject;
RGSSBrower::UnEmbedBrowserObjectPtr		*RGSSBrower::lpUnEmbedBrowserObject;
RGSSBrower::DisplayHTMLPagePtr			*RGSSBrower::lpDisplayHTMLPage;
RGSSBrower::DisplayHTMLStrPtr			*RGSSBrower::lpDisplayHTMLStr;*/
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
	/*hHtmlLite = LoadLibrary(L"cwebpage.dll");
	assert(hHtmlLite);
	// Get pointers to the EmbedBrowserObject, DisplayHTMLPage, DisplayHTMLStr, and UnEmbedBrowserObject
	// functions, and store them in some globals.

	// Get the address of the EmbedBrowserObject() function. NOTE: Only Reginald has this one
	lpEmbedBrowserObject = (EmbedBrowserObjectPtr *)GetProcAddress((HINSTANCE)hHtmlLite, "EmbedBrowserObject");
	assert(lpEmbedBrowserObject);
	// Get the address of the UnEmbedBrowserObject() function. NOTE: Only Reginald has this one
	lpUnEmbedBrowserObject = (UnEmbedBrowserObjectPtr *)GetProcAddress((HINSTANCE)hHtmlLite, "UnEmbedBrowserObject");
	assert(lpUnEmbedBrowserObject);
	// Get the address of the DisplayHTMLPagePtr() function
	lpDisplayHTMLPage = (DisplayHTMLPagePtr *)GetProcAddress((HINSTANCE)hHtmlLite, "DisplayHTMLPage");
	assert(lpDisplayHTMLPage);
	// Get the address of the DisplayHTMLStr() function
	lpDisplayHTMLStr = (DisplayHTMLStrPtr *)GetProcAddress((HINSTANCE)hHtmlLite, "DisplayHTMLStr");
	assert(lpDisplayHTMLStr);*/
	//runtime->rb_eval_string_protect("class Brower;def initialize(x,y,w,h,cb) ;@@hwnds<<CBrower.newwin(x,y,w,h,cb);end;end",x);
	//	hHtmlLite = LoadLibrary(L"htmllite.dll");
	//	assert(hHtmlLite);
	//	assert(GetProcAddress(hHtmlLite,(char *)7));
	//	((bool (__stdcall*)(HINSTANCE))GetProcAddress(hHtmlLite,(char *)7))(gameplayer->hInstance);

}

bool RGSSBrower::Install()
{

	//OleInitialize(NULL);
	//pos=SetupWndHook((WNDPROC)WebProc);
	return true;
}
LRESULT RGSSBrower::WebProc(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM lParam)
{
	/*if (Msg==WM_NOTIFY)
	{
	NMHDR* nhd = (NMHDR*)lParam;
	if (browers.find(nhd->hwndFrom)!=browers.end()&&nhd->code==1000)//HTMLLITE_CODE_LEFTCLICK
	{
	LPNMHTMLLITE nhds = (LPNMHTMLLITE)lParam;
	RV rvs[1];
	rvs[0]=(runtime->INT2FIX(nhds->linkid));
	if (runtime->rb_funcall2(hwnd2Func.find(nhd->hwndFrom)->second,runtime->rb_intern("call"),1,rvs)==runtime->Qtrue)
	{
	delete[] rvs;
	return true;
	}
	delete[] rvs;
	}
	}*/
	//return CallNext(hWnd,Msg,wParam,lParam,pos);
	if (Msg==WM_CREATE)
	{

		//	lpEmbedBrowserObject(hWnd);

	}
	return DefWindowProc(hWnd,Msg,wParam,lParam);
}
extern FILE* LOG;
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
	CWebbrowser *cWeb = new CWebbrowser(rtl.g_hwnd);

	cWeb->OpenWebBrowser();

	VARIANT myurl;
	VariantInit(&myurl);
	myurl.vt = VT_BSTR;
	myurl.bstrVal = SysAllocString(L"http://www.baidu.com");

	cWeb->OpenURL(&myurl);
	/*VariantClear(&myurl);*/
	//CWebbrowser *cWeb = new CWebbrowser(rtl.g_hwnd);
	//cWeb->OpenUrl((USHORT*)L"http://www.baidu.com/");
	//cWeb->ReSize(50,50);
	//hwnd2Web.insert(make_pair(rtl.g_hwnd,cWeb));
	//IStorage * _pStorage;
	//StgCreateDocfile(0,STGM_READWRITE | STGM_SHARE_EXCLUSIVE | STGM_DIRECT | STGM_CREATE,0,&_pStorage);
	//OleCreate( CLSID_WebBrowser,IID_IOleObject,OLERENDER_DRAW, 0 , this, _pStorage, (void**)&_pOleObj );
	//	UpdateWindow(rtl.g_hwnd);
	return runtime->INT2FIX((int)rtl.g_hwnd);
}

void RGSSBrower::movewindow(RV obj)
{
	RTL rtl = OBJ2RTL.find(obj)->second;
	MoveWindow(rtl.g_hwnd,rtl.x,rtl.y,rtl.w,rtl.h,true);
	//CWebbrowser *cWeb = hwnd2Web.find(rtl.g_hwnd)->second;
	//cWeb->ReSize(rtl.w,rtl.h);
	UpdateWindow(rtl.g_hwnd);
}
RV RGSSBrower::dm_dispose(RV obj)
{
	RTL rtl = OBJ2RTL.find(obj)->second;
	DestroyWindow(rtl.g_hwnd);
	browers.erase(rtl.g_hwnd);
	hwnd2Func.erase(rtl.g_hwnd);
	OBJ2RTL.erase(obj);
	return runtime->Qnil;
}
RGSSBrower::RGSSBrower(void)
{
}


RGSSBrower::~RGSSBrower(void)
{
}
