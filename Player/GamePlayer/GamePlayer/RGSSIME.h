#pragma once
#include "abstractrgssextension.h"
class RGSSIME :
	public AbstractRGSSExtension
{
public:
	RGSSIME(void);
	~RGSSIME(void);
	static bool activeIME;
	static RV STARTCOMPOSITION;
	static RV COMPOSITION;
	static RV CHANGECANDIDATE;
	static RV ENDCOMPOSITION;
	static RV mRGSSIME;
	static RV CHAR;
	static HIMC imeContext;

	static bool dm_startIME(RV obj);
	static bool dm_stopIME(RV obj);
	static bool dm_setupcb(RV obj,RV _STARTCOMPOSITION,RV _COMPOSITION,RV _CHANGECANDIDATE,RV _ENDCOMPOSITION,RV _CHAR);
	static RV dm_ImmGetCompositionString(RV obj);
	static RV dm_ImmGetCandidateList(RV obj);
	static LRESULT WINAPI IMMWndProcHook(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam);
	static void InitRuby();
	static bool Install();
	static int pos;
};

