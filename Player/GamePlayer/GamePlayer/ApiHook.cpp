#include "ApiHook.h"
#include <stdio.h>
//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

#define OPEN_FLAGS ( PROCESS_VM_OPERATION | PROCESS_VM_READ | PROCESS_VM_WRITE )

CApiHook :: CApiHook ()
{
	InitializeCriticalSection (& m_cs );
}

CApiHook ::~ CApiHook ()
{
	CloseHandle ( hProc );
	DeleteCriticalSection (& m_cs );
}

void CApiHook :: SetHookOn ( void )
{
	DWORD dwOldFlag ;

	if ( WriteProcessMemory ( hProc , m_lpHookFunc , m_NewFunc , 5 , 0 ))
	{
		return ;
	}
	return ;
}

void CApiHook :: SetHookOff ( void )
{
	DWORD dwOldFlag ;

	if ( WriteProcessMemory ( hProc , m_lpHookFunc , m_OldFunc , 5 , 0 ))
	{
		return ;
	}
	return ;
}

BOOL CApiHook :: Initialize ( LPCWSTR lpLibFileName , LPCSTR lpProcName , FARPROC lpNewFunc )
{
	HMODULE hModule ;

	hModule = LoadLibrary ( lpLibFileName );
	if ( NULL == hModule )
		return FALSE ;

	m_lpHookFunc = GetProcAddress ( hModule , lpProcName );
	if ( NULL == m_lpHookFunc )
		return FALSE ;

	DWORD dwProcessID = GetCurrentProcessId ();
	DWORD dwOldFlag ;
	hProc = GetCurrentProcess ( /*OPEN_FLAGS,0,dwProcessID*/ );

	if ( hProc == NULL )
	{
		return FALSE ;
	}

	if ( ReadProcessMemory ( hProc , m_lpHookFunc , m_OldFunc , 5 , 0 ))
	{
		m_NewFunc [ 0 ]= 0xe9 ;
		DWORD * pNewFuncAddress ;
		pNewFuncAddress =( DWORD *)& m_NewFunc [ 1 ];
		* pNewFuncAddress =( DWORD ) lpNewFunc -( DWORD ) m_lpHookFunc - 5 ;

		return TRUE ;
	}

	return FALSE ;
}

void CApiHook::Lock()
{
	EnterCriticalSection (& m_cs );
}

void CApiHook::Unlock()
{
	LeaveCriticalSection (& m_cs );
}