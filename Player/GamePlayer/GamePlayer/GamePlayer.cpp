#include "GamePlayer.h"
#include <cassert>
GamePlayer::GamePlayer(HINSTANCE _hInstance, HINSTANCE _hPrevInstance, LPSTR _lpCmdLine, int _nCmdShow,int width,int height)
{
	hInstance=_hInstance;
	hPrevInstance=_hPrevInstance;
	lpCmdLine=_lpCmdLine;
	nCmdShow=_nCmdShow;
	pWndClassName  = L"RGSSX Player";
	pDefaultLibrary = L"RGSS300.dll";
	pDefaultTitle  = L"Untitled";
	pDefaultScripts = L"Data\\Scripts.rvdata2";
	nScreenWidth = width;
	nScreenHeight = height;
	nEvalErrorCode = 6;
	g_hWnd = NULL;
	DWORD len = ::GetModuleFileNameW(hInstance, szAppPath, MAX_PATH);
	for (--len; len > 0; --len)
	{
		if (szAppPath[len] == L'\\' || szAppPath[len] == L'/')
		{
			szAppPath[len] = 0;
			break;
		}
	}
	::SetCurrentDirectoryW(szAppPath);
	// ini文件路径
	len = ::GetModuleFileNameW(hInstance, szIniPath, MAX_PATH);
	szIniPath[len - 1] = L'i';
	szIniPath[len - 2] = L'n';
	szIniPath[len - 3] = L'i';

	// 加密包路径
	len = ::GetModuleFileNameW(hInstance, szRgssadPath, MAX_PATH);
	for (--len; len > 0; --len)
	{
		if (szRgssadPath[len] == L'.')
		{
			szRgssadPath[len + 1] = L'r';
			szRgssadPath[len + 2] = L'g';
			szRgssadPath[len + 3] = L's';
			szRgssadPath[len + 4] = L's';
			szRgssadPath[len + 5] = L'3';
			szRgssadPath[len + 6] = L'a';
			szRgssadPath[len + 7] = 0;
			break;
		}
	}

	// ini文件存在
	if (GetFileAttributesW(szIniPath) != INVALID_FILE_ATTRIBUTES)
	{
		//GetPrivateProfileStringW(L"Game", L"Library2", pDefaultLibrary, szLibrary, MAX_PATH, szIniPath);
		wcscpy_s(szLibrary, pDefaultLibrary);
		GetPrivateProfileStringW(L"Game", L"Title",  pDefaultTitle,   szTitle, MAX_PATH, szIniPath);
		//GetPrivateProfileStringW(L"Game", L"Scripts", pDefaultScripts, szScripts, MAX_PATH, szIniPath);
		wcscpy_s(szScripts, pDefaultScripts);
	}
	else
	{
		wcscpy_s(szLibrary, pDefaultLibrary);
		wcscpy_s(szTitle, pDefaultTitle);
		wcscpy_s(szScripts, pDefaultScripts);
	}

	if (GetFileAttributesW(szRgssadPath) != INVALID_FILE_ATTRIBUTES)
		pRgssad = szRgssadPath;

}
HWND GamePlayer::StartWindow()
{
	// 创建窗口
	WNDCLASSW winclass;

	winclass.style = CS_DBLCLKS | CS_OWNDC | CS_HREDRAW | CS_VREDRAW;
	winclass.lpfnWndProc = DefWindowProc;
	winclass.cbClsExtra  = 0;
	winclass.cbWndExtra  = 0;
	winclass.hInstance  = hInstance;
	winclass.hIcon   = LoadIcon(hInstance, MAKEINTRESOURCE(101));
	winclass.hCursor  = LoadCursor(NULL, IDC_ARROW);
	winclass.hbrBackground = (HBRUSH)GetStockObject(BLACK_BRUSH);
	winclass.lpszMenuName = NULL; 
	winclass.lpszClassName = pWndClassName;

	if (!RegisterClassW(&winclass))
	{
		ShowErrorMsg(g_hWnd, szTitle, L"注册窗口类失败 %s。", pWndClassName);
		return 0;
	}
	


	DWORD dwStyle = WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX | WS_VISIBLE| WS_CLIPCHILDREN;
	HWND th=::CreateWindowEx(WS_EX_WINDOWEDGE,pWndClassName,L"v",WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX,0,0,600,400,0,0,hInstance,0);
	RECT rt1;
	
	GetClientRect(th,&rt1);
	int width = nScreenWidth + (600-rt1.right-rt1.left);//GetSystemMetrics(SM_CXFIXEDFRAME) * 2;
	int height = nScreenHeight + (400-rt1.bottom-rt1.top);
	RECT rt;{
		rt.left  = (GetSystemMetrics(SM_CXSCREEN) - width) / 2;
		//rt.top = (GetSystemMetrics(SM_CYSCREEN) - height) / 2;
		rt.top  = (GetSystemMetrics(SM_CYMAXIMIZED) - nScreenHeight) / 2 - GetSystemMetrics(SM_CYCAPTION);
		rt.right = rt.left + width;
		rt.bottom = rt.top + height;
	}
	DestroyWindow(th);
	g_hWnd = ::CreateWindowEx(WS_EX_WINDOWEDGE, pWndClassName, szTitle, dwStyle,
		rt.left, rt.top, /*rt.right - rt.left*/width, /*rt.bottom - rt.top*/height, 0, 0, hInstance, 0);
	if (!g_hWnd)
	{
		ShowErrorMsg(g_hWnd, szTitle, L"创建窗口失败 %s。", szTitle);
		___exit();
		return (HWND)-1;
	}
	// 控制台
	if (strcmp(lpCmdLine, "console") == 0)
	{
		if (AllocConsole())
		{
			SetConsoleTitle(L"RGSS Console");
			FILE* frw = NULL;
			freopen_s(&frw, "conout$", "w", stdout);
		}
	}

	ShowWindow(g_hWnd, SW_SHOW);
	return g_hWnd;
}
bool GamePlayer::InitRGSS()
{
	// 加载RGSS核心库
	hRgssCore = ::LoadLibraryW(szLibrary);
	if (!hRgssCore)
	{
		DWORD e = ::GetLastError();
		ShowErrorMsg(g_hWnd, szTitle, L"加载RGSS核心库失败 %s。", szLibrary);
		___exit();
		return false;
	}
	pRGSSExInitialize = (RGSSExInitialize)::GetProcAddress(hRgssCore, "RGSSExInitialize");
#define ___get_check(fn)                \
	do                    \
	{                    \
	p##fn = (fn)::GetProcAddress(hRgssCore, #fn);        \
	if (!p##fn)                 \
	{                   \
	ShowErrorMsg(g_hWnd, szTitle, L"获取RGSS核心库导出函数失败 %s。", #fn); \
	___exit();               \
	return false; \
	}                   \
	} while (0)
	{
		___get_check(RGSSSetupRTP);
		___get_check(RGSSSetupFonts);
		___get_check(RGSSInitialize3);
		___get_check(RGSSEval);
		___get_check(RGSSGameMain);
	}
#undef __get_check
	// 1、设置RTP
	wchar_t szRtpName[1024];

	if (!pRGSSSetupRTP(szIniPath, szRtpName, 1024))
	{
		ShowErrorMsg(g_hWnd, szTitle, L"没有发现 RGSS-RTP %s。", szRtpName);
		___exit();
		return false;
	}
	// 2、初始化
	pRGSSInitialize3(hRgssCore);

	// 2.1、扩展库初始化（补丁模式）
	if (pRGSSExInitialize)
	{
		if (!pRGSSExInitialize(g_hWnd))
		{
			ShowErrorMsg(g_hWnd, szTitle, L"RGSS扩展库初始化失败 %s。", L"RGSSExInitialize");
			___exit();
			return false;
		}
	}
	pRGSSSetupFonts();
	pRgssad=L"";
	// 3、设置运行时变量
#ifdef _DEBUG
	if (strcmp(lpCmdLine, "btest") == 0)
	{
		pRgssad = 0;
		pRGSSEval("$TEST = true");
		pRGSSEval("$BTEST = true");
	}
	else 
	{
		if (strcmp(lpCmdLine, "test") == 0)
		{
			pRgssad = 0;
			pRGSSEval("$TEST = true");
		}
		else
			pRGSSEval("$TEST = false");

		pRGSSEval("$BTEST = false");
	}
	return true;
#endif
}
void GamePlayer::RunGame()
{
	//char buff[255];
	//sprintf(buff,"%d",g_hWnd);
	//MessageBoxA(0,buff,"hwnd",0);
	assert(g_hWnd);
	assert(szScripts);
	pRGSSGameMain(g_hWnd, szScripts,  (wchar_t **) L"");
	___exit();
}
HWND GamePlayer::__rgssx_get_hwnd()
{
	return g_hWnd;
}
void GamePlayer::ShowErrorMsg(HWND hWnd, const wchar_t* szTitle, const wchar_t* szFormat, ...)
{
	static wchar_t szError[1024];

	va_list ap;
	va_start(ap, szFormat);
	vswprintf_s(szError, szFormat, ap);
	va_end(ap);

	MessageBoxW(hWnd, szError, szTitle, MB_ICONERROR);
}
GamePlayer::~GamePlayer(void)
{
	___exit();
}
void GamePlayer::___exit()
{
	if (hRgssCore)
	{
		FreeLibrary(hRgssCore);
		hRgssCore = NULL;
	}

	if (g_hWnd)
	{
		DestroyWindow(g_hWnd);
		g_hWnd = NULL;
	}

	UnregisterClassW(pWndClassName, hInstance);
}

WNDPROC GamePlayer::HookWndProc(WNDPROC newProc)
{
	return (WNDPROC)SetWindowLong(g_hWnd,GWL_WNDPROC,(LONG)newProc);
}
