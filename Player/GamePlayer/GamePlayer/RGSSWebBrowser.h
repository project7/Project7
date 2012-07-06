#pragma once
#include "abstractrgssextension.h"
#include <exdisp.h>
#include <mshtml.h>
#include <exdisp.h>
#include <mshtmhst.h>
#include <ole2.h>
#include <oleidl.h>
#include <crtdbg.h>
class RGSSWebBrowser :
	public AbstractRGSSExtension
{
public:
	RGSSWebBrowser(void);
	~RGSSWebBrowser(void);
	RV dm_new_webb(RV obj,RV url,RV ruby_x,RV ruby_y,RV ruby_width,RV ruby_height);
	RV dm_hwnd(RV obj);


	static bool Install();
	static void InitRuby();
	static LRESULT WINAPI WebWndProcHook(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam);

	int x,y,width,height;
	HWND g_hwnd;
	IWebBrowser2 *webBrowser2;
	typedef struct _IOleInPlaceFrameEx {
		IOleInPlaceFrame	*frame;
		HWND				window;
	}IOleInPlaceFrameEx;
	typedef struct __IOleInPlaceSiteEx {
		IOleInPlaceSite		*inplace;	
		///////////////////////////////////////////////////
		IOleInPlaceFrameEx	*frame;
	} _IOleInPlaceSiteEx;

	typedef struct __IOleClientSiteEx {
		IOleClientSite		*client;	
		_IOleInPlaceSiteEx	inplace;

	} _IOleClientSiteEx;
	HRESULT STDMETHODCALLTYPE Storage_QueryInterface(IStorage FAR* This, REFIID riid, LPVOID FAR* ppvObj);
	HRESULT STDMETHODCALLTYPE Storage_AddRef(IStorage FAR* This);
	HRESULT STDMETHODCALLTYPE Storage_Release(IStorage FAR* This);
	HRESULT STDMETHODCALLTYPE Storage_CreateStream(IStorage FAR* This, const WCHAR *pwcsName, DWORD grfMode, DWORD reserved1, DWORD reserved2, IStream **ppstm);
	HRESULT STDMETHODCALLTYPE Storage_OpenStream(IStorage FAR* This, const WCHAR * pwcsName, void *reserved1, DWORD grfMode, DWORD reserved2, IStream **ppstm);
	HRESULT STDMETHODCALLTYPE Storage_CreateStorage(IStorage FAR* This, const WCHAR *pwcsName, DWORD grfMode, DWORD reserved1, DWORD reserved2, IStorage **ppstg);
	HRESULT STDMETHODCALLTYPE Storage_OpenStorage(IStorage FAR* This, const WCHAR * pwcsName, IStorage * pstgPriority, DWORD grfMode, SNB snbExclude, DWORD reserved, IStorage **ppstg);
	HRESULT STDMETHODCALLTYPE Storage_CopyTo(IStorage FAR* This, DWORD ciidExclude, IID const *rgiidExclude, SNB snbExclude,IStorage *pstgDest);
	HRESULT STDMETHODCALLTYPE Storage_MoveElementTo(IStorage FAR* This, const OLECHAR *pwcsName,IStorage * pstgDest, const OLECHAR *pwcsNewName, DWORD grfFlags);
	HRESULT STDMETHODCALLTYPE Storage_Commit(IStorage FAR* This, DWORD grfCommitFlags);
	HRESULT STDMETHODCALLTYPE Storage_Revert(IStorage FAR* This);
	HRESULT STDMETHODCALLTYPE Storage_EnumElements(IStorage FAR* This, DWORD reserved1, void * reserved2, DWORD reserved3, IEnumSTATSTG ** ppenum);
	HRESULT STDMETHODCALLTYPE Storage_DestroyElement(IStorage FAR* This, const OLECHAR *pwcsName);
	HRESULT STDMETHODCALLTYPE Storage_RenameElement(IStorage FAR* This, const WCHAR *pwcsOldName, const WCHAR *pwcsNewName);
	HRESULT STDMETHODCALLTYPE Storage_SetElementTimes(IStorage FAR* This, const WCHAR *pwcsName, FILETIME const *pctime, FILETIME const *patime, FILETIME const *pmtime);
	HRESULT STDMETHODCALLTYPE Storage_SetClass(IStorage FAR* This, REFCLSID clsid);
	HRESULT STDMETHODCALLTYPE Storage_SetStateBits(IStorage FAR* This, DWORD grfStateBits, DWORD grfMask);
	HRESULT STDMETHODCALLTYPE Storage_Stat(IStorage FAR* This, STATSTG * pstatstg, DWORD grfStatFlag);

};

