#pragma once
#pragma comment(lib, "ws2_32.lib") 
#include "AbstractRGSSExtension.h"
using namespace std;

class RGSSLiteHTTP:public AbstractRGSSExtension
{
public:
	static RGSS3Runtime::VALUE mCLiteHTTP;
	static bool available;

	RGSSLiteHTTP(void);
	~RGSSLiteHTTP(void);
#define RBOOL(val) (val)?runtime->Qtrue:runtime->Qfalse;
	static void InitRuby(){
		InitWSA();

		mCLiteHTTP = sruntime->rb_define_module("CLiteHTTP");
		runtime->rb_define_module_function(mCLiteHTTP,"available?",(RGSS3Runtime::RubyFunc)dm_get_available,0);
		runtime->rb_define_module_function(mCLiteHTTP,"request",(RGSS3Runtime::RubyFunc)dm_request,-1);
	}
	static RGSS3Runtime::VALUE RUBYCALL dm_get_available(RGSS3Runtime::VALUE obj){
		return RBOOL(available);
	}
	static void InitWSA(){
		WORD wVersionRequested;  
		WSADATA wsaData;  
		int err;  
	   
		available = false;

		wVersionRequested = MAKEWORD(2, 2);  
	   
		err = WSAStartup(wVersionRequested,&wsaData);  
		if (err != 0) {  
			return;
		}  
		if (LOBYTE(wsaData.wVersion) != 2 ||HIBYTE(wsaData.wVersion) != 2) {  
			WSACleanup();  
			return;
		}  

		available = true;
	}
	static RGSS3Runtime::VALUE RUBYCALL dm_request(int argc, RGSS3Runtime::VALUE *argv,RGSS3Runtime::VALUE obj)
	{
		int hsock;
		int * p_int ;
		hsock = socket(AF_INET, SOCK_STREAM, 0);
		if(hsock == -1){
			return runtime->INT2FIX(WSAGetLastError());
		}

		p_int = (int*)malloc(sizeof(int));
		*p_int = 1;
		if( (setsockopt(hsock, SOL_SOCKET, SO_REUSEADDR, (char*)p_int, sizeof(int)) == -1 )){
			free(p_int);
			return runtime->INT2FIX(WSAGetLastError());
		}
		free(p_int);

		struct sockaddr_in my_addr;
		
		my_addr.sin_family = AF_INET ;
		my_addr.sin_port = htons(runtime->FIX2INT(argv[1]));

		hostent * host;
		host = gethostbyname(runtime->rb_string_value_ptr(&argv[0]));
		if (host == NULL)
		{
			return runtime->INT2FIX(WSAGetLastError());
		}
		char * ip = inet_ntoa(*(struct in_addr *)*host->h_addr_list);

		memset(&(my_addr.sin_zero), 0, 8);
		my_addr.sin_addr.s_addr = inet_addr(ip);

		if( connect( hsock, (struct sockaddr*)&my_addr, sizeof(my_addr)) == SOCKET_ERROR ){
			return runtime->INT2FIX(WSAGetLastError());
		}

		char* body = runtime->rb_string_value_ptr(&argv[2]);
		if( (send(hsock, body, strlen(body),0))==SOCKET_ERROR){
			return runtime->INT2FIX(WSAGetLastError());
		}

		std::string tmp;
		char* buffer;
		int bytecount, thiscount;
		tmp = "";
		bytecount = 0;
		buffer = (char *)malloc(1024);
		while (true){
			thiscount = (recv(hsock, buffer, 1024, 0));
			if (thiscount == SOCKET_ERROR)
				return runtime->INT2FIX(WSAGetLastError());
			if (thiscount == 0)
				break;
			tmp.append(buffer, thiscount);
			bytecount += thiscount;
		}
		free(buffer);

		closesocket(hsock);
		const char* res = tmp.c_str();
		return runtime->rb_str_new(res,strlen(res));
	}
	static bool Install()
	{
		return true;
	}
#undef RBOOL
};

RGSS3Runtime::VALUE RGSSLiteHTTP::mCLiteHTTP;
bool RGSSLiteHTTP::available;