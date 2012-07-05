#include "RGSSIME.h"


bool RGSSIME::activeIME;
RV RGSSIME::STARTCOMPOSITION;
RV RGSSIME::COMPOSITION;
RV RGSSIME::CHANGECANDIDATE;
RV RGSSIME::ENDCOMPOSITION;

bool RGSSIME::dm_startIME(RV obj)
{
	imeContext = ImmGetContext(gameplayer->g_hWnd);
	activeIME=true;
}
bool RGSSIME::dm_stopIME(RV obj){
	activeIME=false;
}
bool RGSSIME::dm_setupcb(RV obj,RV _STARTCOMPOSITION,RV _COMPOSITION,RV _CHANGECANDIDATE,RV _ENDCOMPOSITION,RV _CHAR){
	STARTCOMPOSITION=_STARTCOMPOSITION;
	COMPOSITION=_COMPOSITION;
	CHANGECANDIDATE=_CHANGECANDIDATE;
	ENDCOMPOSITION=_ENDCOMPOSITION;
	CHAR=_CHAR;
}
RV RGSSIME::dm_ImmGetCompositionString(RV obj){

}
RV RGSSIME::dm_ImmGetCandidateList(RV obj){
	LPCANDIDATELIST candidate;
	//UINT32 size = ImmGetCandidateList(
}
void RGSSIME::InitRuby(){
	mRGSSIME = runtime->rb_define_module("IME");
	RDM(mRGSSIME,"start",(RF)dm_startIME,0);
	RDM(mRGSSIME,"stop",(RF)dm_stopIME,0);
	RDM(mRGSSIME,"set_callback_func",(RF)dm_setupcb,5);
	RDM(mRGSSIME,"gcs",(RF)dm_ImmGetCompositionString,0);
	RDM(mRGSSIME,"gcl",(RF)dm_ImmGetCandidateList,0);
}
bool RGSSIME::Install(){
	pos = SetupWndHook(IMMWndProcHook);
}
// ImmGetIMEFileName看着办
LRESULT WINAPI RGSSIME::IMMWndProcHook(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam)
{
	if (activeIME)
	{
		if (Msg==WM_INPUTLANGCHANGE)
		{
			return ;//Handle this message
		}
		if (Msg==WM_IME_STARTCOMPOSITION)
		{
			// Prepare ImmGetCompositionString 获得最后字符
		}
		if (Msg==WM_IME_COMPOSITION)
		{
			if (IParam==GCS_COMPSTR||IParam==GCS_COMPREADSTR)
			{
				//Prepare ImmGetCompositionString
			}
		}
		if (Msg==WM_IME_NOTIFY)
		{
			// ImmGetCandidateList 候选字操作
		}
		if (Msg==WM_CHAR)
		{
			// 英语字符输入
		}
	}
	if (Msg==WM_IME_SETCONTEXT)
	{
		if (wParam==1)
		{
			imeContext = ImmGetContext(gameplayer->g_hWnd);
			ImmAssociateContext(gameplayer->g_hWnd,imeContext);
		}
	}
	if (Msg==WM_GETDLGCODE)
	{
		return DLGC_WANTALLKEYS;
	}

	CallNext(hWnd,Msg,wParam,IParam,pos);
}

RGSSIME::RGSSIME(void)
{
}


RGSSIME::~RGSSIME(void)
{
}
