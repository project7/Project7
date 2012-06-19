#include "ExtendX.h"

using namespace std;
#pragma comment(lib, "user32.lib")
#pragma comment(lib, "shlwapi.lib")
#pragma comment(lib, "advapi32.lib")
#pragma comment(lib, "psapi.lib")
#pragma comment(lib, "seiran.lib")
extern "C"{
	#include <stdint.h>
	int32_t disasm(uint8_t *data, char *output, int outbufsize, int segsize,
	            int32_t offset, int autosync, uint32_t prefer);
	int32_t eatbyte(uint8_t *data, char *output, int outbufsize, int segsize);

};
CExtendX::CExtendX(GamePlayer* _cGamePlayer):IExtendModule(_cGamePlayer)
{
	
}
void CExtendX::getModuleList(int pid, HMODULE *hMod, LPDWORD size){
        HANDLE hProcess = OpenProcess(2035711, false, pid);
        if (hProcess)
                if (EnumProcessModules(hProcess, hMod, *size, size))
                        return;
        *size = 0;
}
HMODULE CExtendX::findModuleByLint(int str){
        HMODULE hMod[1024]={0};	
        DWORD size = sizeof(hMod);
        getModuleList(GetCurrentProcessId(), hMod, &size);
        char ret[1024];	
        for(int i=0; i<size; ++i){
                if (hMod[i]){
                        static char filename[1024];
                        filename[0] = 0;
                        GetModuleFileNameA(hMod[i],  filename, 1024);
                        PathStripPathA(filename);
                        for(char *p = filename; *p; ++p) *p = tolower(*p);
                        if( *(int *)filename == str ){
                                return hMod[i];
                        }
                }
        }
        return 0;
}
DWORD CExtendX::findFFImethodCode(RGSS3Runtime &rs3, const string &predef, const string &method){
	int x = rs3.litr[predef];	
	if (x==0) return -1;
	int y = distance(rs3.code.begin(), lower_bound(rs3.code.begin(), rs3.code.end(), x));
	while(rs3.lit.find(rs3.code[y])==rs3.lit.end() || rs3.lit[rs3.code[y]] != method)
		++y;
	if (rs3.lit.find(rs3.code[y])!=rs3.lit.end() && rs3.lit[rs3.code[y]] == method){
		--y;
		return y;
	}
	return -1;
}
DWORD CExtendX::findFFImethod(RGSS3Runtime &rs3, const string &predef, const string &method){
	int y = findFFImethodCode(rs3, predef, method);
	if (y==-1) return 0;
	return *(DWORD *)(rs3.code[y]+1);
}
int CExtendX::findCodeFromAddr(RGSS3Runtime &rs3, int addr){
	int y = distance(rs3.code.begin(), lower_bound(rs3.code.begin(), rs3.code.end(), addr));
	return y;
}
//e8
DWORD CExtendX::find_call_value_from(RGSS3Runtime &rs3, int y){
	while (*(uint8_t *)rs3.code[y] != 0xe8) ++y;
	if (*(uint8_t *)rs3.code[y] == 0xe8){
		return rs3.code[y] + *(DWORD *)(rs3.code[y]+1) + 5;
	}
	return 0;
}

DWORD CExtendX::find_rb_define_module_function(RGSS3Runtime &rs3){
	int y = findFFImethodCode(rs3, "Graphics", "update");
	return find_call_value_from(rs3, y);
}
void CExtendX::initnode(RGSS3Runtime &rs3){
	uint8_t *p = (uint8_t *) rs3.mi.lpBaseOfDll;
	VirtualProtect(p, rs3.mi.SizeOfImage, PAGE_EXECUTE_READWRITE, 0);
	uint8_t *q = p + rs3.mi.SizeOfImage;
	uint8_t *r = p;
	uint8_t *s = p;
	rs3.code.clear();
	rs3.lit.clear();
	rs3.litr.clear();
	char output[1024];
	static const int validstate = PAGE_EXECUTE_READWRITE | PAGE_EXECUTE_READ  | PAGE_READWRITE | PAGE_READONLY;
	while (p < q-0x10){
		
		int len = disasm(p, output, 64, 32, 0,0,1);
		if (len == 0) len = 1;
		rs3.code.push_back((int)p);
		if ((int)p - (int)r >= 0x7fff){
			rs3.RGSSEval("Graphics.update");
			double value = double(p-s) * 100 / rs3.mi.SizeOfImage;
			fprintf(stderr, "%02.2f%%", double(p-s) * 100 / rs3.mi.SizeOfImage);
			for(int i=value/5; i; --i){fprintf(stderr, ".");}
			fprintf(stderr, "\r");
			r = p;
		}
		if ( *p == 0x68 ){
			const char *d = *(const char **)(p+1);
			MEMORY_BASIC_INFORMATION mbi;
			VirtualQuery(d,&mbi,sizeof(mbi));
			if (mbi.State == MEM_COMMIT  && ((int)d > 0) && ((int)d < (int)q + rs3.mi.SizeOfImage)){
				rs3.lit.insert(make_pair<int, string>((int)p, string(d)));
				string x = d;
				if (rs3.litr.find(x)==rs3.litr.end()){

					rs3.litr.insert(make_pair<string, int>(string(x), (int)p));
				}
			}
		}
		p+=len;
	}
	fprintf(stderr, "........done\n");
}

void CExtendX::initmodule(RGSS3Runtime &rs3, HMODULE rgss){
	rs3.process = GetCurrentProcess();
	rs3.module = rgss;
	(FARPROC &)rs3.RGSSEval = GetProcAddress(rgss, "RGSSEval");
	GetModuleInformation(rs3.process, rs3.module, &rs3.mi, sizeof(rs3.mi));	
	assert(rs3.RGSSEval);
}
void CExtendX::preinitconsole(RGSS3Runtime &rs3){
	rs3.wndConsole = GetConsoleWindow();
	if (!rs3.wndConsole){
		AllocConsole();
		freopen("CONOUT$", "w", stderr);
//		SetConsoleOutputCP(65001);
	}
}

DWORD CExtendX::rbx_define_module_function(int argc, int *argv, DWORD obj){
	RGSS3Runtime *rs3 = getRuntime();
	char s[1024];
	rs3->rb_define_module_function( argv[0], *(const char **)(argv[1] + rs3->rofs), (DWORD(*)(...))((argv[2]^1)>>1), (argv[3]^1)>>1);
	return 2;
}

DWORD CExtendX::rbx_addtest(int argc, int *argv){
	return argv[0] + argv[1] - 1;
}
void CExtendX::postinitconsole(RGSS3Runtime &rs3){
	if (!rs3.wndConsole){
		fclose(stderr);
		FreeConsole();
	}
}

RGSS3Runtime* CExtendX::getRuntime(){
    static RGSS3Runtime rs3;
    static int init = false;
    if (init) return &rs3;
        HINSTANCE rgss = findModuleByLint('ssgr');
        assert(rgss);	
	preinitconsole(rs3);
	initmodule(rs3, rgss);
	initnode(rs3);
	assert(rs3.litr["Graphics"]);
	(DWORD &)rs3.Graphics_update        = findFFImethod(rs3, "Graphics", "update");
	(DWORD &)rs3.rb_define_module_function       = find_rb_define_module_function(rs3);
	int code = findCodeFromAddr(rs3, (int)rs3.RGSSEval);
	assert(code!=-1);
	(DWORD &)rs3.rb_eval_string_protect = find_call_value_from(rs3, code);
	assert(rs3.rb_eval_string_protect);
	assert(rs3.Graphics_update);
	assert(rs3.rb_define_module_function);
	DWORD x = rs3.rb_eval_string_protect("RUBY_VERSION.tr('.', '0').to_i", 0);
	x = (x^1)>>1;
	if (x >= 10900)	

		rs3.rofs = 8;
	else
		rs3.rofs = 12;
	postinitconsole(rs3);
        init = true;
	return &rs3;
}
void CExtendX::run_once(){
	//your things
	RGSS3Runtime *rs3 = getRuntime();
	rs3->rbx = rs3->rb_eval_string_protect("module RBX; self; end;", 0);
	rs3->rb_define_module_function(rs3->rbx, "add", (DWORD(*)(...))rbx_addtest, -1);
//	rs3->RGSSEval("eval File.read('run.rb')");
	VirtualProtect(rs3->Graphics_update, 8, PAGE_EXECUTE_READWRITE, 0);	
	QWORD &manipulate = *(QWORD *)rs3->Graphics_update;	
	manipulate = oldbytes;
}
template <typename Src, typename Dest>
Dest union_cast(Src x){
  union {
     Src s; 
     Dest d;
  } = {x};
  return d;
}
void CExtendX::go(int){
	RGSS3Runtime *rs3 = getRuntime();
	VirtualProtect(rs3->Graphics_update, 8, PAGE_EXECUTE_READWRITE, 0);
	QWORD &manipulate = *(QWORD *)rs3->Graphics_update;
	oldbytes = manipulate;
	QWORD offset = (DWORD)(union_cast<DWORD(*)(...)>(run_once)) - (DWORD)&manipulate - 5;
	manipulate = 0xE9 |  (offset << 8) | (manipulate & 0xFFFFFF0000000000uLL) ;
}

CExtendX::~CExtendX(void)
{
}
