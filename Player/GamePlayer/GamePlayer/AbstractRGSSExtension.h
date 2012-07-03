#pragma once
#include "RGSS3Runtime.h"
#include "GamePlayer.h"
#define HookerTest 
class AbstractRGSSExtension
{
public:
	AbstractRGSSExtension();
	static void InitRuby(RGSS3Runtime *_runtime,GamePlayer * _gameplayer){runtime=_runtime;gameplayer=_gameplayer;};
   	static bool Install();
	~AbstractRGSSExtension(void);
	static RGSS3Runtime *runtime;
	static GamePlayer * gameplayer;
	static int SetupWndHook(WNDPROC proc);
	static WNDPROC oldProc;
	static LRESULT CallNextW(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam);
	static LRESULT CallNext(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam,int pos);
	static LRESULT WINAPI WndProcHookManger(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam);
	//static vector<WNDPROC> calllist;
	static int maxpos;
	static void InitRuby();
	struct WndList
	{

		struct Node
		{
			WNDPROC value;
			Node* next;
		};
		Node* first;
		Node* get(int x);
		void insert(WNDPROC v);
		WndList()
		{
			first=NULL;
		}
	};
	static WndList calllist;
};

