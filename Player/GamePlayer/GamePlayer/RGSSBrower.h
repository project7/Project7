#pragma once
#include <set>
#include "AbstractRGSSExtension.h"
#include "WebBrowser.h"

class RGSSBrower:AbstractRGSSExtension
{
public:
	RGSSBrower(void);
	~RGSSBrower(void);
	static void InitRuby();
   	static bool Install();
	static RV rbcBrower;
	static HMODULE hHtmlLite;
	static LRESULT WebProc(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM lParam);
	static map<HWND,RV> hwnd2Func;
	static map<HWND,CWebbrowser*> hwnd2Web;
	static set<HWND> browers;
	static int pos;
	static WNDCLASSEX		wc;
	struct RTL
	{
		int x,y,w,h;
		HWND g_hwnd;
	};
	static map<RV,RTL> OBJ2RTL;
	static RV dm_initialize(RV obj,RV url,RV x,RV y,RV w,RV h,RV callback);
	static RV dm_dispose(RV obj);
	static void movewindow(RV obj);
	static RV dm_get_x(RV obj){RTL rtl = OBJ2RTL.find(obj)->second;return runtime->INT2FIX(rtl.x);};static RV dm_set_x(RV obj,RV v){RTL rtl = OBJ2RTL.find(obj)->second;rtl.x=runtime->FIX2INT(v);movewindow(obj);return runtime->Qnil;};
    static RV dm_get_y(RV obj){RTL rtl = OBJ2RTL.find(obj)->second;return runtime->INT2FIX(rtl.y);};static RV dm_set_y(RV obj,RV v){RTL rtl = OBJ2RTL.find(obj)->second;rtl.y=runtime->FIX2INT(v);movewindow(obj);return runtime->Qnil;};
    static RV dm_get_w(RV obj){RTL rtl = OBJ2RTL.find(obj)->second;return runtime->INT2FIX(rtl.w);};static RV dm_set_w(RV obj,RV v){RTL rtl = OBJ2RTL.find(obj)->second;rtl.w=runtime->FIX2INT(v);movewindow(obj);return runtime->Qnil;};
    static RV dm_get_h(RV obj){RTL rtl = OBJ2RTL.find(obj)->second;return runtime->INT2FIX(rtl.h);};static RV dm_set_h(RV obj,RV v){RTL rtl = OBJ2RTL.find(obj)->second;rtl.h=runtime->FIX2INT(v);movewindow(obj);return runtime->Qnil;};
	/*long WINAPI EmbedBrowserObject(HWND);
	#define EMBEDBROWSEROBJECT EmbedBrowserObject
	typedef long WINAPI EmbedBrowserObjectPtr(HWND);

	void WINAPI UnEmbedBrowserObject(HWND);
	#define UNEMBEDBROWSEROBJECT UnEmbedBrowserObject
	typedef long WINAPI UnEmbedBrowserObjectPtr(HWND);

	long WINAPI DisplayHTMLPage(HWND, LPCTSTR);
	#define DISPLAYHTMLPAGE DisplayHTMLPage
	typedef long WINAPI DisplayHTMLPagePtr(HWND, LPCTSTR);

	long WINAPI DisplayHTMLStr(HWND, LPCTSTR);
	#define DISPLAYHTMLSTR DisplayHTMLStr
	typedef long WINAPI DisplayHTMLStrPtr(HWND, LPCTSTR);
	static EmbedBrowserObjectPtr		*lpEmbedBrowserObject;
	static UnEmbedBrowserObjectPtr		*lpUnEmbedBrowserObject;
	static DisplayHTMLPagePtr			*lpDisplayHTMLPage;
	static DisplayHTMLStrPtr			*lpDisplayHTMLStr;*/

	
typedef struct NMHTMLLITE {
  DWORD hwndFrom;     
  DWORD idFrom;                 
  DWORD code; 
  DWORD linkid;
  RECT  linkrc;
} NMHTMLLITE, *LPNMHTMLLITE;

};

