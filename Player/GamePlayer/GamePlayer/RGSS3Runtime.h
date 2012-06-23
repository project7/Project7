#pragma once
#include <Windows.h>
#include <shlwapi.h>
#include <cstring>
#include <tlhelp32.h>
#include <cassert>
#include <vector>
#include <string>
#include <algorithm>
#include <psapi.h>
#include <map>
#include <iostream>
using namespace std;

struct RGSS3Runtime{
	HANDLE process;
	HMODULE module;
	MODULEINFO mi;
	HWND wndConsole;
	DWORD rbx;
	DWORD (*RGSSEval)(const char *);
	DWORD rubyversion;
	void (__stdcall *Graphics_update)();
	void (*rb_define_module_function)(DWORD, const char *, DWORD (*)(...), int);
	DWORD (*rb_eval_string_protect) (const char *, int *);
	vector <int> code;       //  code point
	map <int, string> lit;
	map <string, int> litr;  // string is the literal
	int rofs;
};