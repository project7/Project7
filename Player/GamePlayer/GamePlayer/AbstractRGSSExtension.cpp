#include "AbstractRGSSExtension.h"
WNDPROC AbstractRGSSExtension::oldProc;
GamePlayer * AbstractRGSSExtension::gameplayer;
RGSS3Runtime * AbstractRGSSExtension::runtime;
//vector<WNDPROC> AbstractRGSSExtension::calllist;
AbstractRGSSExtension::WndList AbstractRGSSExtension::calllist;
int AbstractRGSSExtension::maxpos;

AbstractRGSSExtension::AbstractRGSSExtension(){
}
#ifdef HookerTest
FILE *LOG;
#endif
void AbstractRGSSExtension::WndList::insert(WNDPROC v)
{
	Node *p=first;
	while (p->next!=NULL) p=p->next;
	Node *np = new Node;
	np->value = v;
	np->next=NULL;
	p->next=np;
}
AbstractRGSSExtension::WndList::Node* AbstractRGSSExtension::WndList::get(int x)
{
	Node *p=first;
	//
	if (x==0) 
	{
		return first;
	}
	for (int i=0;i<x;i++,p=p->next);
	return p;
}
AbstractRGSSExtension::~AbstractRGSSExtension(void)
{
}

int AbstractRGSSExtension::SetupWndHook(WNDPROC proc)
{
	calllist.insert(proc);
	maxpos+=1;
	return maxpos-1;
}
LRESULT AbstractRGSSExtension::CallNextW(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam)
{
	#ifdef HookerTest
	fprintf(LOG,"CallNextW:%d\n\r",oldProc);fflush(LOG);
	#endif
	return CallWindowProc(oldProc,hWnd,Msg,wParam,IParam);
}
LRESULT AbstractRGSSExtension::CallNext(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam,int pos)
{
	#ifdef HookerTest
	fprintf(LOG,"Callnext:%d\n\r",pos);fflush(LOG);
	#endif
	return CallWindowProc(calllist.get(pos)->value,hWnd,Msg,wParam,IParam);
}
bool AbstractRGSSExtension::Install()
{
	#ifdef HookerTest
	LOG=fopen("loghooker.txt","w");
	#endif
	//calllist.insert((WNDPROC)CallNextW);
	//SetupWndHook((WNDPROC)CallNextW);
	calllist.first= new WndList::Node();
	calllist.first->value = (WNDPROC)CallNextW;
	calllist.first->next=NULL;
	maxpos=0;
	oldProc=gameplayer->HookWndProc(WndProcHookManger);
	return true;
}
LRESULT WINAPI AbstractRGSSExtension::WndProcHookManger(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam)
{
	//if (!FuckYou)
	return CallNext(hWnd,Msg,wParam,IParam,maxpos);//calllist.get(1)->value(hWnd,Msg,wParam,IParam);
	//else
	//return CallNextW(hWnd,Msg,wParam,IParam);
}