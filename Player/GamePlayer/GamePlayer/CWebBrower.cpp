#include "WebBrowser.h"

/*==================
| 构造和析构 |
==================
*/
#include <stdio.h>
#ifdef HookerTest
extern FILE* LOG;
#endif
#define RECTWIDTH(rect) (((rect).right)-((rect).left))
#define RECTHEIGHT(rect) (((rect).bottom)-((rect).top))

#ifdef HookerTest
#define NULLTEST_SE(fn,wstr) if (fn==0) {fwprintf(LOG,L"%s\n",wstr);fflush(LOG);goto RETURN;}
#define HRTEST_SE(fn,wstr) if (fn!=S_OK) {fwprintf(LOG,L"%s\n",wstr);fflush(LOG);goto RETURN;}
#define NULLTEST(fn) if (fn==0) {goto RETURN;}
#define HRTEST_E(fn,wstr) if (fn!=S_OK) {fwprintf(LOG,L"%s\n",wstr);fflush(LOG);goto RETURN;}
#else
#define NULLTEST_SE(fn,wstr) if (fn==0) {goto RETURN;}
#define HRTEST_SE(fn,wstr) if (fn!=S_OK) {goto RETURN;}
#define NULLTEST(fn) if (fn==0) {goto RETURN;}
#define HRTEST_E(fn,wstr) if (fn!=S_OK) {goto RETURN;}
#endif
Webbrowser::Webbrowser(void):
	_refNum(0),
	//_rcWebWnd(0),
	_bInPlaced(false),
	_bExternalPlace(false),
	_bCalledCanInPlace(false),
	_bWebWndInited(false),
	_pOleObj(NULL), 
	_pInPlaceObj(NULL), 
	_pStorage(NULL), 
	_pWB2(NULL), 
	_pHtmlDoc2(NULL), 
	_pHtmlDoc3(NULL), 
	_pHtmlWnd2(NULL), 
	_pHtmlEvent(NULL)
{
	::memset( (PVOID)&_rcWebWnd,0,sizeof(_rcWebWnd));
	HRTEST_SE( OleInitialize(0),L"Failed in Initialize Ole");
	HRTEST_SE( StgCreateDocfile(0,STGM_READWRITE | STGM_SHARE_EXCLUSIVE | STGM_DIRECT | STGM_CREATE,0,&_pStorage),L"ERROR:StgCreateDocfile");
	HRTEST_SE( OleCreate(CLSID_WebBrowser,IID_IOleObject,OLERENDER_DRAW,0,this,_pStorage,(void**)&_pOleObj),L"Create Ole Failed");
	HRTEST_SE( _pOleObj->QueryInterface(IID_IOleInPlaceObject,(LPVOID*)&_pInPlaceObj),L"Create OleInPlaceObject Failed");
	GetWebBrowser2();
	OleUninitialize();
RETURN:

	return;
}

Webbrowser::~Webbrowser(void)
{
}


/*==================
|IUnknown methods|
==================
*/
STDMETHODIMP Webbrowser::QueryInterface(REFIID iid,void**ppvObject)
{
	*ppvObject = 0;
	if ( iid == IID_IOleClientSite )
		*ppvObject = (IOleClientSite*)this;
	if ( iid == IID_IUnknown )
		*ppvObject = this;
	if ( iid == IID_IDispatch )
		*ppvObject = (IDispatch*)this;
	if ( _bExternalPlace == false)
	{
		if ( iid == IID_IOleInPlaceSite )
			*ppvObject = (IOleInPlaceSite*)this;
		if ( iid == IID_IOleInPlaceFrame )
			*ppvObject = (IOleInPlaceFrame*)this;
		if ( iid == IID_IOleInPlaceUIWindow )
			*ppvObject = (IOleInPlaceUIWindow*)this;
	}
	if ( iid == DIID_DWebBrowserEvents2 )
		*ppvObject = (DWebBrowserEvents2 *)this;
	/*
	这里是一点走私货, 留在以后讲,如果有机会,你可以发现,原来如此简单.

	if ( iid == IID_IDocHostUIHandler)
	*ppvObject = (IDocHostUIHandler*)this;
	*/
	if ( *ppvObject )
	{
		AddRef();
		return S_OK;
	}
	return E_NOINTERFACE;
}

STDMETHODIMP_(ULONG) Webbrowser::AddRef()
{
	return ::InterlockedIncrement( &_refNum );
}

STDMETHODIMP_(ULONG) Webbrowser::Release()
{
	return ::InterlockedDecrement( &_refNum );
}

/*
=====================
| IDispatch Methods |
=====================
*/
HRESULT _stdcall Webbrowser::GetTypeInfoCount(
	unsigned int * pctinfo) 
{
	return E_NOTIMPL;
}

HRESULT _stdcall Webbrowser::GetTypeInfo(
	unsigned int iTInfo,
	LCID lcid,
	ITypeInfo FAR* FAR* ppTInfo) 
{
	return E_NOTIMPL;
}

HRESULT _stdcall Webbrowser::GetIDsOfNames(REFIID riid, 
										   OLECHAR FAR* FAR* rgszNames, 
										   unsigned int cNames, 
										   LCID lcid, 
										   DISPID FAR* rgDispId )
{
	return E_NOTIMPL;
}

HRESULT _stdcall Webbrowser::Invoke(
	DISPID dispIdMember,
	REFIID riid,
	LCID lcid,
	WORD wFlags,
	DISPPARAMS* pDispParams,
	VARIANT* pVarResult,
	EXCEPINFO* pExcepInfo,
	unsigned int* puArgErr)
{
	/*
	// DWebBrowserEvents2
	if( dispIdMember == DISPID_DOCUMENTCOMPLETE)
	{
	DocumentComplete(pDispParams->rgvarg[1].pdispVal,pDispParams->rgvarg[0].pvarVal);
	return S_OK;
	}
	if( dispIdMember == DISPID_BEFORENAVIGATE2)
	{
	BeforeNavigate2( pDispParams->rgvarg[6].pdispVal,
	pDispParams->rgvarg[5].pvarVal,
	pDispParams->rgvarg[4].pvarVal,
	pDispParams->rgvarg[3].pvarVal,
	pDispParams->rgvarg[2].pvarVal,
	pDispParams->rgvarg[1].pvarVal,
	pDispParams->rgvarg[0].pboolVal);
	return S_OK;
	}
	*/
	return E_NOTIMPL;
}

/*
========================
|IOleClientSite methods|
========================
*/
STDMETHODIMP Webbrowser::SaveObject()
{
	return S_OK;
}

STDMETHODIMP Webbrowser::GetMoniker(DWORD dwA,DWORD dwW,IMoniker**pm)
{
	*pm = 0;
	return E_NOTIMPL;
}

STDMETHODIMP Webbrowser::GetContainer(IOleContainer**pc)
{
	*pc = 0;
	return E_FAIL;
}

STDMETHODIMP Webbrowser::ShowObject()
{
	return S_OK;
}

STDMETHODIMP Webbrowser::OnShowWindow(BOOL f)
{
	return S_OK;
}

STDMETHODIMP Webbrowser::RequestNewObjectLayout()
{
	return S_OK;
}


/*
=========================
|IOleInPlaceSite methods|
=========================
*/
STDMETHODIMP Webbrowser::GetWindow(HWND *p)
{
	*p = GetHWND();
	return S_OK;
}

STDMETHODIMP Webbrowser::ContextSensitiveHelp(BOOL)
{
	return E_NOTIMPL;
}

STDMETHODIMP Webbrowser::CanInPlaceActivate()//If this function return S_FALSE, AX cannot activate in place!
{
	if ( _bInPlaced )//Does WebBrowser Control already in placed?
	{
		_bCalledCanInPlace = true;
		return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP Webbrowser::OnInPlaceActivate()
{
	return S_OK;
}

STDMETHODIMP Webbrowser::OnUIActivate()
{
	return S_OK;
}

STDMETHODIMP Webbrowser::GetWindowContext(IOleInPlaceFrame** ppFrame,IOleInPlaceUIWindow **ppDoc,LPRECT r1,LPRECT r2,LPOLEINPLACEFRAMEINFO o)
{

	*ppFrame = (IOleInPlaceFrame*)this;
	AddRef();
	*ppDoc = NULL;

	::GetClientRect( GetHWND() ,&_rcWebWnd );
	*r1 = _rcWebWnd;
	*r2 = _rcWebWnd;

	o->cb = sizeof(OLEINPLACEFRAMEINFO);
	o->fMDIApp = false;
	o->hwndFrame = GetParent( GetHWND() );
	o->haccel = 0;
	o->cAccelEntries = 0;

	return S_OK;
}

STDMETHODIMP Webbrowser::Scroll(SIZE s)
{
	return E_NOTIMPL;
}

STDMETHODIMP Webbrowser::OnUIDeactivate(int)
{
	return S_OK;
}

STDMETHODIMP Webbrowser::OnInPlaceDeactivate()
{
	return S_OK;
}

STDMETHODIMP Webbrowser::DiscardUndoState()
{
	return S_OK;
}

STDMETHODIMP Webbrowser::DeactivateAndUndo()
{
	return S_OK;
}

STDMETHODIMP Webbrowser::OnPosRectChange(LPCRECT)
{
	return S_OK;
}


/*
==========================
|IOleInPlaceFrame methods|
==========================
*/
STDMETHODIMP Webbrowser::GetBorder(LPRECT l)
{
	::GetClientRect( GetHWND() ,&_rcWebWnd );
	*l = _rcWebWnd;
	return S_OK;
}

STDMETHODIMP Webbrowser::RequestBorderSpace(LPCBORDERWIDTHS b)
{
	return S_OK;
}

STDMETHODIMP Webbrowser::SetBorderSpace(LPCBORDERWIDTHS b)
{
	return S_OK;
}

STDMETHODIMP Webbrowser::SetActiveObject(IOleInPlaceActiveObject*pV,LPCOLESTR s)
{
	return S_OK;
}

STDMETHODIMP Webbrowser::SetStatusText(LPCOLESTR t)
{
	return E_NOTIMPL;
}

STDMETHODIMP Webbrowser::EnableModeless(BOOL f)
{
	return E_NOTIMPL;
}

STDMETHODIMP Webbrowser::TranslateAccelerator(LPMSG,WORD)
{
	return E_NOTIMPL;
}

HRESULT _stdcall Webbrowser::RemoveMenus(HMENU h)
{
	return E_NOTIMPL;
}

HRESULT _stdcall Webbrowser::InsertMenus(HMENU h,LPOLEMENUGROUPWIDTHS x)
{
	return E_NOTIMPL;
}
HRESULT _stdcall Webbrowser::SetMenu(HMENU h,HOLEMENU hO,HWND hw)
{
	return E_NOTIMPL;
}


/*
====================
|DWebBrowserEvents2|
====================
*/
/* 走私货,以后再讲
void 
Webbrowser::DocumentComplete( IDispatch *pDisp,VARIANT *URL)
{
//老天保佑,多好的函数啊.
return ;
}



void 
Webbrowser::BeforeNavigate2( IDispatch *pDisp,VARIANT *&url,VARIANT *&Flags,VARIANT *&TargetFrameName,VARIANT *&PostData,VARIANT *&Headers,VARIANT_BOOL *&Cancel)
{
PCWSTR pcwApp = L"app:";
if( url->vt != VT_BSTR )
return;
if( 0 == _wcsnicmp( pcwApp, url->bstrVal,wcslen(pcwApp)) )
{
*Cancel = VARIANT_TRUE;
_OnHtmlCmd( url->bstrVal+wcslen(pcwApp) );
return;
}
*Cancel = VARIANT_FALSE;
}
*/
/*
=====================
| IDocHostUIHandler |
=====================
*/
/*
传说中的IDocHostUIHanler,同样留在以后讲
HRESULT Webbrowser::ShowContextMenu(
DWORD dwID,
POINT *ppt,
IUnknown *pcmdtReserved,
IDispatch *pdispReserved){return E_NOTIMPL;}

HRESULT Webbrowser::GetHostInfo(DOCHOSTUIINFO *pInfo){return E_NOTIMPL;}

HRESULT Webbrowser:: ShowUI( 
DWORD dwID,
IOleInPlaceActiveObject *pActiveObject,
IOleCommandTarget *pCommandTarget,
IOleInPlaceFrame *pFrame,
IOleInPlaceUIWindow *pDoc){return E_NOTIMPL;}

HRESULT Webbrowser:: HideUI( void){return E_NOTIMPL;}

HRESULT Webbrowser:: UpdateUI( void){return E_NOTIMPL;}

//HRESULT Webbrowser:: EnableModeless( 
// BOOL fEnable){return E_NOTIMPL;}

HRESULT Webbrowser:: OnDocWindowActivate( 
BOOL fActivate){return E_NOTIMPL;}

HRESULT Webbrowser:: OnFrameWindowActivate( 
BOOL fActivate){return E_NOTIMPL;}

HRESULT Webbrowser:: ResizeBorder( 
LPCRECT prcBorder,
IOleInPlaceUIWindow *pUIWindow,
BOOL fRameWindow){return E_NOTIMPL;}

HRESULT Webbrowser:: TranslateAccelerator( 
LPMSG lpMsg,
const GUID *pguidCmdGroup,
DWORD nCmdID){return E_NOTIMPL;}

HRESULT Webbrowser:: GetOptionKeyPath( 
LPOLESTR *pchKey,
DWORD dw){return E_NOTIMPL;}

HRESULT Webbrowser:: GetDropTarget( 
IDropTarget *pDropTarget,
IDropTarget **ppDropTarget)
{
return E_NOTIMPL;//使用默认拖拽
//return S_OK;//自定义拖拽
}

HRESULT Webbrowser:: GetExternal( IDispatch **ppDispatch)
{
return E_NOTIMPL;
}

HRESULT Webbrowser:: TranslateUrl( 
DWORD dwTranslate,
OLECHAR *pchURLIn,
OLECHAR **ppchURLOut){return E_NOTIMPL;}

HRESULT Webbrowser:: FilterDataObject( 
IDataObject *pDO,
IDataObject **ppDORet){return E_NOTIMPL;}
*/


/*
===============
|Other Methods|
===============
*/
IWebBrowser2* 
	Webbrowser::GetWebBrowser2()
{
	if( _pWB2 != NULL )
		return _pWB2;
	NULLTEST_SE( _pOleObj,L"Ole object is empty");
	HRTEST_SE( _pOleObj->QueryInterface(IID_IWebBrowser2,(void**)&_pWB2),L"QueryInterface IID_IWebBrowser2 Failed");
	return _pWB2;
RETURN:
	return NULL;
}

IHTMLDocument2* 
	Webbrowser::GetHTMLDocument2()
{
	if( _pHtmlDoc2 != NULL )
		return _pHtmlDoc2;
	IWebBrowser2* pWB2 = NULL;
	NULLTEST((pWB2 = GetWebBrowser2()));//GetWebBrowser2已经将错误原因交给LastError.
	IDispatch* pDp = NULL;
	HRTEST_SE(pWB2->get_Document(&pDp),L"DWebBrowser2::get_Document Error");
	HRTEST_SE(pDp->QueryInterface(IID_IHTMLDocument2,(void**)&_pHtmlDoc2),L"QueryInterface IID_IHTMLDocument2 Failed");
	return _pHtmlDoc2;
RETURN:
	return NULL;
}
IHTMLDocument3* 
	Webbrowser::GetHTMLDocument3()
{
	if( _pHtmlDoc3 != NULL )
		return _pHtmlDoc3;

	IWebBrowser2* pWB2 = NULL;
	NULLTEST((pWB2 = GetWebBrowser2()));//GetWebBrowser2已经将错误原因交给LastError.
	IDispatch* pDp = NULL;
	HRTEST_SE(pWB2->get_Document(&pDp),L"DWebBrowser2::get_Document Error");
	HRTEST_SE(pDp->QueryInterface(IID_IHTMLDocument3,(void**)&_pHtmlDoc3),L"QueryInterface IID_IHTMLDocument3 Failed");
	return _pHtmlDoc3;
RETURN:
	return NULL;
}

IHTMLWindow2*
	Webbrowser::GetHTMLWindow2()
{
	if( _pHtmlWnd2 != NULL)
		return _pHtmlWnd2;
	IHTMLDocument2* pHD2 = GetHTMLDocument2();
	NULLTEST( pHD2 );
	HRTEST_SE( pHD2->get_parentWindow(&_pHtmlWnd2),L"IHTMLWindow2::get_parentWindow Error" );
	return _pHtmlWnd2;
RETURN:
	return NULL;
}

IHTMLEventObj* 
	Webbrowser::GetHTMLEventObject()
{
	if( _pHtmlEvent != NULL )
		return _pHtmlEvent;
	IHTMLWindow2* pHW2;
	NULLTEST( (pHW2 = GetHTMLWindow2()) );
	HRTEST_SE( pHW2->get_event(&_pHtmlEvent),L"IHTMLWindow2::get_event Error");
	return _pHtmlEvent;
RETURN:
	return NULL;
}

BOOL 
	Webbrowser::SetWebRect(LPRECT lprc)
{
	BOOL bRet = FALSE;
	if( false == _bInPlaced )//尚未OpenWebBrowser操作,直接写入_rcWebWnd
	{
		_rcWebWnd = *lprc;
	}
	else//已经打开WebBrowser,通过 IOleInPlaceObject::SetObjectRects 调整大小
	{
		SIZEL size;
		size.cx = RECTWIDTH(*lprc);
		size.cy = RECTHEIGHT(*lprc);

		IOleObject* pOleObj;
		NULLTEST( (pOleObj= _GetOleObject()));
		HRTEST_E( pOleObj->SetExtent( 1,&size ),L"SetExtent Error");

		IOleInPlaceObject* pInPlace;
		NULLTEST( (pInPlace = _GetInPlaceObject()));
		HRTEST_E( pInPlace->SetObjectRects(lprc,lprc),L"SetObjectRects Error");
		_rcWebWnd = *lprc;
	}
	bRet = TRUE;
RETURN:
	return bRet;
}

BOOL 
	Webbrowser::OpenWebBrowser()
{
	BOOL bRet = FALSE;
	NULLTEST_SE( _GetOleObject(),L"ActiveX object is empty" );//对于本身的实现函数,其自身承担错误录入工作

	if( (RECTWIDTH(_rcWebWnd) && RECTHEIGHT(_rcWebWnd)) == 0 )
		::GetClientRect( GetHWND() ,&_rcWebWnd);//设置WebBrowser的大小为窗口的客户区大小.

	if( _bInPlaced == false )// Activate In Place
	{
		_bInPlaced = true;//_bInPlaced must be set as true, before INPLACEACTIVATE, otherwise, once DoVerb, it would return error;
		_bExternalPlace = 0;//lParam;

		//	fwprintf(LOG,L"%d\n",&_rcWebWnd);fflush(LOG);
		//DoVerb(browserObject, OLEIVERB_SHOW, NULL, (IOleClientSite *)_iOleClientSiteEx, -1, hwnd, &rect)
		HRTEST_E( (_GetOleObject()->DoVerb(OLEIVERB_INPLACEACTIVATE,0,this,0, GetHWND() ,&_rcWebWnd)),L"Error DoVerb about INPLACE");
		_bInPlaced = true;

		//* 挂接DWebBrwoser2Event
		IConnectionPointContainer* pCPC = NULL;
		IConnectionPoint* pCP = NULL;
		HRTEST_E( GetWebBrowser2()->QueryInterface(IID_IConnectionPointContainer,(void**)&pCPC),L"Faild in Each IConnectionPointContainer Interface");
		HRTEST_E( pCPC->FindConnectionPoint( DIID_DWebBrowserEvents2,&pCP),L"FindConnectionPoint FAILD");
		DWORD dwCookie = 0;
		HRTEST_E( pCP->Advise( (IUnknown*)(void*)this,&dwCookie),L"IConnectionPoint::Advise FAILD");
	}


	bRet = TRUE;
RETURN:
	return bRet;
}

BOOL 
	Webbrowser::OpenURL(VARIANT* pVarUrl)
{
	BOOL bRet = FALSE;

	HRTEST_E( GetWebBrowser2()->Navigate2( pVarUrl,0,0,0,0),L"GetWebBrowser2 faild");
	bRet = TRUE;
RETURN:
	return bRet;
}
HRESULT _stdcall CWebbrowser::Invoke(
	DISPID dispIdMember,
	REFIID riid,
	LCID lcid,
	WORD wFlags,
	DISPPARAMS* pDispParams,
	VARIANT* pVarResult,
	EXCEPINFO* pExcepInfo,
	unsigned int* puArgErr)
{
	//if (Invoke(dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)==E_NOTIMPL)
	//{
	if( dispIdMember == DISPID_DOCUMENTCOMPLETE)
		return S_OK;
	if( dispIdMember == DISPID_BEFORENAVIGATE2)
	{
		//BeforeNavigate2( IDispatch *pDisp,VARIANT *&url,VARIANT *&Flags,VARIANT *&TargetFrameName,VARIANT *&PostData,VARIANT *&Headers,VARIANT_BOOL *&Cancel)
		/*
		BeforeNavigate2( pDispParams->rgvarg[6].pdispVal,
		pDispParams->rgvarg[5].pvarVal,
		pDispParams->rgvarg[4].pvarVal,
		pDispParams->rgvarg[3].pvarVal,
		pDispParams->rgvarg[2].pvarVal,
		pDispParams->rgvarg[1].pvarVal,
		pDispParams->rgvarg[0].pboolVal);
		*/
		//MessageBox(0,L"hi",L"hi",0);
		if( pDispParams->rgvarg[5].pvarVal->vt != VT_BSTR ) return S_OK;
		_bstr_t b = (pDispParams->rgvarg[5].pvarVal->bstrVal);
		RGSS3Runtime::VALUE target=sruntime->rb_str_new(b,strlen(b));

		if (sruntime->rb_funcall2(func,sruntime->rb_intern("call"),1,&target)==RGSS3Runtime::Qfalse)
		{
			(*(pDispParams->rgvarg[0].pboolVal)) = VARIANT_TRUE;
		}
		else
		{
			(*(pDispParams->rgvarg[0].pboolVal)) = VARIANT_FALSE;
		}
		return S_OK;
	}
	if (dispIdMember == DISPID_NEWWINDOW3)
	{
		//OpenURL(pDispParams->rgvarg[1].pvarVal);
		VARIANT myurl;
		VariantInit(&myurl);
		myurl.vt = pDispParams->rgvarg[0].vt;
		myurl.bstrVal = pDispParams->rgvarg[0].bstrVal;
		GetWebBrowser2()->Navigate2(&myurl,0,0,0,0);
	
		(*(pDispParams->rgvarg[3].pboolVal)) = VARIANT_TRUE;
		return S_OK;
	}
	//}
	return E_NOTIMPL;
}