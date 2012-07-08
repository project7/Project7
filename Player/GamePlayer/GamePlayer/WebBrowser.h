// Webbrowser.h: interface for the CWebbrowser class.
//
//////////////////////////////////////////////////////////////////////
#ifndef _INCLUDE_WEBBROWSER_FILE_H_
#define _INCLUDE_WEBBROWSER_FILE_H_
#pragma once
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <oleidl.h>
#include <ExDisp.h>
#include <mshtml.h>
#include <mshtmhst.h>
//////////////////////////////////////////////////////////////////////////
// 使用前调用OleInitialize初始化OLE

class Webbrowser:
	public IDispatch,
	public IOleClientSite,
	public IOleInPlaceSite,
	public IOleInPlaceFrame/*,
						   public IDocHostUIHandler*/
{
public:
	Webbrowser();
	~Webbrowser(void);
public:
	// IUnknown methods
	virtual STDMETHODIMP QueryInterface(REFIID iid,void**ppvObject);
	virtual STDMETHODIMP_(ULONG) AddRef();
	virtual STDMETHODIMP_(ULONG) Release();

	// IDispatch Methods
	HRESULT _stdcall GetTypeInfoCount(unsigned int * pctinfo);
	HRESULT _stdcall GetTypeInfo(unsigned int iTInfo,LCID lcid,ITypeInfo FAR* FAR* ppTInfo);
	HRESULT _stdcall GetIDsOfNames(REFIID riid,OLECHAR FAR* FAR* rgszNames,unsigned int cNames,LCID lcid,DISPID FAR* rgDispId);
	HRESULT _stdcall Invoke(DISPID dispIdMember,REFIID riid,LCID lcid,WORD wFlags,DISPPARAMS FAR* pDispParams,VARIANT FAR* pVarResult,EXCEPINFO FAR* pExcepInfo,unsigned int FAR* puArgErr);


	// IOleClientSite methods
	virtual STDMETHODIMP SaveObject();
	virtual STDMETHODIMP GetMoniker(DWORD dwA,DWORD dwW,IMoniker**pm);
	virtual STDMETHODIMP GetContainer(IOleContainer**pc);
	virtual STDMETHODIMP ShowObject();
	virtual STDMETHODIMP OnShowWindow(BOOL f);
	virtual STDMETHODIMP RequestNewObjectLayout();


	// IOleInPlaceSite methods
	virtual STDMETHODIMP GetWindow(HWND *p);
	virtual STDMETHODIMP ContextSensitiveHelp(BOOL);
	virtual STDMETHODIMP CanInPlaceActivate();
	virtual STDMETHODIMP OnInPlaceActivate();
	virtual STDMETHODIMP OnUIActivate();
	virtual STDMETHODIMP GetWindowContext(IOleInPlaceFrame** ppFrame,IOleInPlaceUIWindow **ppDoc,LPRECT r1,LPRECT r2,LPOLEINPLACEFRAMEINFO o);
	virtual STDMETHODIMP Scroll(SIZE s);
	virtual STDMETHODIMP OnUIDeactivate(int);
	virtual STDMETHODIMP OnInPlaceDeactivate();
	virtual STDMETHODIMP DiscardUndoState();
	virtual STDMETHODIMP DeactivateAndUndo();
	virtual STDMETHODIMP OnPosRectChange(LPCRECT);

	// IOleInPlaceFrame methods
	virtual STDMETHODIMP GetBorder(LPRECT l);
	virtual STDMETHODIMP RequestBorderSpace(LPCBORDERWIDTHS);
	virtual STDMETHODIMP SetBorderSpace(LPCBORDERWIDTHS w);
	virtual STDMETHODIMP SetActiveObject(IOleInPlaceActiveObject*pV,LPCOLESTR s);
	virtual STDMETHODIMP InsertMenus(HMENU h,LPOLEMENUGROUPWIDTHS x);
	virtual STDMETHODIMP SetMenu(HMENU h,HOLEMENU hO,HWND hw);
	virtual STDMETHODIMP RemoveMenus(HMENU h);
	virtual STDMETHODIMP SetStatusText(LPCOLESTR t);
	virtual STDMETHODIMP EnableModeless(BOOL f);
	virtual STDMETHODIMP TranslateAccelerator(LPMSG,WORD);

protected:
	virtual HWND GetHWND(){return NULL;};//继承的类应该实现这个方法,告诉WebBrowser,到底用哪一个HWND放置WebBrowser

	// 内部工具函数
private:
	inline IOleObject* _GetOleObject(){return _pOleObj;};
	inline IOleInPlaceObject* _GetInPlaceObject(){return _pInPlaceObj;};

	//外部方法
public:
	IWebBrowser2*      GetWebBrowser2();
	IHTMLDocument2*    GetHTMLDocument2();
	IHTMLDocument3*    GetHTMLDocument3();
	IHTMLWindow2*      GetHTMLWindow2();
	IHTMLEventObj*     GetHTMLEventObject();


	BOOL       SetWebRect(LPRECT lprc);
	BOOL       OpenWebBrowser();
	BOOL       OpenURL(VARIANT* pVarUrl);


	// 内部数据
protected:
	long   _refNum;
private:
	RECT  _rcWebWnd;
	bool  _bInPlaced;
	bool  _bExternalPlace;
	bool  _bCalledCanInPlace;
	bool  _bWebWndInited;
private:
	//指针
	IOleObject*                 _pOleObj; 
	IOleInPlaceObject*          _pInPlaceObj;
	IStorage*                   _pStorage;
	IWebBrowser2*               _pWB2;
	IHTMLDocument2*             _pHtmlDoc2;
	IHTMLDocument3*             _pHtmlDoc3;
	IHTMLWindow2*               _pHtmlWnd2;
	IHTMLEventObj*              _pHtmlEvent;
};


class CWebbrowser :
	public Webbrowser
{
public:
	CWebbrowser(HWND _hwnd){hWnd=_hwnd;};
	HWND						hWnd;
	virtual  HWND GetHWND(){return hWnd;}
};
#endif
