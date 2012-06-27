#pragma once
#include <Windows.h>
#include <shlwapi.h>
#include <cstring>
#include <cassert>
#include <vector>
#include <string>
#include <algorithm>
#include <map>
#include <iostream>
#include <stddef.h>
#include <stdarg.h>
#include <stdint.h>
#include <limits.h>
#include "GamePlayer.h"
using namespace std;
#define RUBYCALL				__cdecl
struct RGSS3Runtime{
#pragma region 类型定义
	typedef unsigned long			VALUE;
	typedef unsigned long			ID;
	static const VALUE				Qfalse	= 0;
	static const VALUE				Qtrue	= 2;
	static const VALUE				Qnil	= 4;
	static const VALUE				Qundef	= 6;
	static inline bool				RTEST(VALUE v)	{ return ((v & ~Qnil) != 0); }
	static inline bool				NIL_P(VALUE v)	{ return (v == Qnil); }
	typedef long SIGNED_VALUE;
	typedef	unsigned char		u8;
	typedef signed char			s8;
	typedef unsigned short		u16;
	typedef signed short		s16;
	typedef unsigned long		u32;
	typedef signed long			s32;
	typedef unsigned long long	u64;
	typedef signed long long	s64;

	typedef float				f32;
	typedef double				f64;

	typedef volatile u8			vu8;
	typedef volatile s8			vs8;
	typedef volatile u16		vu16;
	typedef volatile s16		vs16;
	typedef volatile u32		vu32;
	typedef volatile s32		vs32;
	typedef volatile u64		vu64;
	typedef volatile s64		vs64;

	typedef volatile f32		vf32;
	typedef volatile f64		vf64;
#pragma endregion
#pragma region Runtime
	HANDLE process;
	HMODULE module;
	HWND wndConsole;
	DWORD rbx;
	DWORD rubyversion;
	RGSS3Runtime(GamePlayer * gp);
#pragma endregion
#pragma region Ruby支持

	typedef VALUE					(RUBYCALL* RubyFunc)(...);
	typedef void					(RUBYCALL* RubyDataFunc)(void*);
private:

	typedef VALUE					(*pfn_rb_const_get)(VALUE, ID);
	typedef void					(*pfn_rb_define_const)(VALUE, const char*, VALUE);
	typedef void					(*pfn_rb_define_global_const)(const char*, VALUE);

	typedef VALUE					(*pfn_rb_iv_get)(VALUE, const char*);
	typedef VALUE					(*pfn_rb_iv_set)(VALUE, const char*, VALUE);

	typedef void*					(*pfn_ruby_xmalloc)(size_t);
	typedef void					(*pfn_ruby_xfree)(void*);

	typedef void					(*pfn_rb_gc_mark)(VALUE);

	typedef void					(*pfn_rb_define_method)( VALUE classmod, char *name, VALUE(*func)(), int argc );
	typedef VALUE					(*pfn_rb_define_class)(const char*, VALUE);
	typedef VALUE					(*pfn_rb_define_module)(const char*);
	typedef VALUE					(*pfn_rb_define_class_under)(VALUE, const char*, VALUE);
	typedef VALUE					(*pfn_rb_define_module_under)(VALUE, const char*);

	typedef	void					(*pfn_rb_define_class_method)(VALUE, const char*, RubyFunc, int);
	typedef	void					(*pfn_rb_define_module_function)(VALUE, const char*, RubyFunc, int);
	typedef	void					(*pfn_rb_define_global_function)(const char*, RubyFunc, int);

	typedef void					(*pfn_rb_define_alloc_func)(VALUE, VALUE (*rb_alloc_func_t)(VALUE));
	typedef void					(*pfn_rb_undef_alloc_func)(VALUE);
	typedef VALUE					(*pfn_rb_data_object_alloc)(VALUE, void*, RubyDataFunc, RubyDataFunc);
	typedef void					(*pfn_rb_undef_method)(VALUE, const char*);
	typedef void					(*pfn_rb_define_alias)(VALUE, const char*, const char*);

	typedef ID						(*pfn_rb_intern)(const char*);
	typedef const char*				(*pfn_rb_id2name)(ID);

	typedef VALUE					(*pfn_rb_funcall)(VALUE, ID, int, ...);
	typedef VALUE					(*pfn_rb_funcall2)(VALUE, ID, int, const VALUE*);
	typedef VALUE					(*pfn_rb_funcall3)(VALUE, ID, int, const VALUE*);
	typedef int						(*pfn_rb_scan_args)(int, const VALUE*, const char*, ...);
	typedef VALUE					(*pfn_rb_call_super)(int, const VALUE*);
	typedef int						(*pfn_rb_respond_to)(VALUE, ID);

	typedef VALUE					(*pfn_rb_eval_string)(const char*);
	typedef VALUE					(*pfn_rb_eval_string_protect)(const char*, int*);

	typedef VALUE					(*pfn_rb_protect)(VALUE (*)(VALUE), VALUE, int*);
	typedef void					(*pfn_rb_raise)(VALUE, const char*, ...);
	typedef VALUE					(*pfn_rb_errinfo)(void);

	typedef VALUE					(*pfn_rb_obj_class)(VALUE);
	typedef VALUE					(*pfn_rb_singleton_class)(VALUE);
	typedef VALUE					(*pfn_rb_obj_is_instance_of)(VALUE, VALUE);
	typedef VALUE					(*pfn_rb_obj_is_kind_of)(VALUE, VALUE);
	typedef const char*				(*pfn_rb_class2name)(VALUE);
	typedef const char*				(*pfn_rb_obj_classname)(VALUE);
	typedef int						(*pfn_rb_type)(VALUE obj);
	typedef void					(*pfn_rb_check_type)(VALUE, int);
	typedef VALUE					(*pfn_rb_convert_type)(VALUE, int, const char *, const char *);

	typedef long					(*pfn_rb_num2long)(VALUE);
	typedef unsigned long			(*pfn_rb_num2ulong)(VALUE);
	typedef double					(*pfn_rb_num2dbl)(VALUE);

	typedef VALUE					(*pfn_rb_int2num)(long);
	typedef VALUE					(*pfn_rb_uint2num)(unsigned long);

	typedef VALUE					(*pfn_rb_str_new)(const char*, long);
	typedef VALUE					(*pfn_rb_str_new2)(const char*);
	typedef VALUE					(*pfn_rb_str_new3)(VALUE);
	typedef void					(*pfn_rb_str_modify)(VALUE);
	typedef VALUE					(*pfn_rb_str_cat)(VALUE, const char*, long);
	typedef VALUE					(*pfn_rb_str_buf_new)(long);
	typedef VALUE					(*pfn_rb_str_buf_append)(VALUE, VALUE);
	typedef VALUE					(*pfn_rb_inspect)(VALUE);
	typedef VALUE					(*pfn_rb_obj_as_string)(VALUE);

	typedef VALUE					(*pfn_rb_ary_new)(void);
	typedef VALUE					(*pfn_rb_ary_new2)(long);
	typedef VALUE					(*pfn_rb_ary_new4)(long, const VALUE*);
	typedef void					(*pfn_rb_ary_store)(VALUE, long, VALUE);
	typedef VALUE					(*pfn_rb_ary_push)(VALUE, VALUE);
	typedef VALUE					(*pfn_rb_ary_pop)(VALUE);
	typedef VALUE					(*pfn_rb_ary_shift)(VALUE);
	typedef VALUE					(*pfn_rb_ary_unshift)(VALUE, VALUE);
	typedef VALUE					(*pfn_rb_ary_entry)(VALUE, long);
	typedef VALUE					(*pfn_rb_ary_clear)(VALUE);

	typedef VALUE					(*pfn_rb_float_new)(double);

	typedef int						(*pfn_rb_block_given_p)(void);
	typedef VALUE					(*pfn_rb_block_proc)(void);

	typedef VALUE					(*pfn_rb_string_value)(volatile VALUE*);
	typedef char*					(*pfn_rb_string_value_ptr)(volatile VALUE*);
	typedef char*					(*pfn_rb_string_value_cstr)(volatile VALUE*);

	typedef char*					(*pfn_rb_string_ptr)(VALUE str);
	typedef long					(*pfn_rb_string_len)(VALUE str);
	typedef VALUE*					(*pfn_rb_array_ptr)(VALUE ary);
	typedef long					(*pfn_rb_array_len)(VALUE ary);
	typedef void*					(*pfn_rb_userdata_ptr)(VALUE d);


	typedef	int						(*pfn_rb_const_defined)(VALUE klass, ID id);
	typedef VALUE					(*pfn_rb_class_new_instance)(int argc, VALUE *argv, VALUE klass);

	VALUE					StringValue(volatile VALUE* str)												{ return rb_string_value(str); }
	char*					StringValuePtr(volatile VALUE* str)												{ return rb_string_value_ptr(str); }
	//char*					StringValueCstr(volatile VALUE* str)											{ return rb_string_value_cstr(str); }


	static const VALUE FL_USHIFT	= 12;

	static const VALUE FL_USER0		= (((VALUE)1)<<(FL_USHIFT+0));
	static const VALUE FL_USER1		= (((VALUE)1)<<(FL_USHIFT+1));
	static const VALUE FL_USER2		= (((VALUE)1)<<(FL_USHIFT+2));
	static const VALUE FL_USER3		= (((VALUE)1)<<(FL_USHIFT+3));
	static const VALUE FL_USER4		= (((VALUE)1)<<(FL_USHIFT+4));
	static const VALUE FL_USER5		= (((VALUE)1)<<(FL_USHIFT+5));
	static const VALUE FL_USER6		= (((VALUE)1)<<(FL_USHIFT+6));
	static const VALUE FL_USER7		= (((VALUE)1)<<(FL_USHIFT+7));
	static const VALUE FL_USER8		= (((VALUE)1)<<(FL_USHIFT+8));
	static const VALUE FL_USER9		= (((VALUE)1)<<(FL_USHIFT+9));
	static const VALUE FL_USER10	= (((VALUE)1)<<(FL_USHIFT+10));
	static const VALUE FL_USER11	= (((VALUE)1)<<(FL_USHIFT+11));
	static const VALUE FL_USER12	= (((VALUE)1)<<(FL_USHIFT+12));
	static const VALUE FL_USER13	= (((VALUE)1)<<(FL_USHIFT+13));
	static const VALUE FL_USER14	= (((VALUE)1)<<(FL_USHIFT+14));
	static const VALUE FL_USER15	= (((VALUE)1)<<(FL_USHIFT+15));
	static const VALUE FL_USER16	= (((VALUE)1)<<(FL_USHIFT+16));
	static const VALUE FL_USER17	= (((VALUE)1)<<(FL_USHIFT+17));
	static const VALUE FL_USER18	= (((VALUE)1)<<(FL_USHIFT+18));
	static const VALUE FL_USER19	= (((VALUE)1)<<(FL_USHIFT+19));

	//	ruby value type
	static const VALUE RUBY_T_NONE   = 0x00;
	static const VALUE RUBY_T_OBJECT = 0x01;
	static const VALUE RUBY_T_CLASS  = 0x02;
	static const VALUE RUBY_T_MODULE = 0x03;
	static const VALUE RUBY_T_FLOAT  = 0x04;
	static const VALUE RUBY_T_STRING = 0x05;
	static const VALUE RUBY_T_REGEXP = 0x06;
	static const VALUE RUBY_T_ARRAY  = 0x07;
	static const VALUE RUBY_T_HASH   = 0x08;
	static const VALUE RUBY_T_STRUCT = 0x09;
	static const VALUE RUBY_T_BIGNUM = 0x0a;
	static const VALUE RUBY_T_FILE   = 0x0b;
	static const VALUE RUBY_T_DATA   = 0x0c;
	static const VALUE RUBY_T_MATCH  = 0x0d;
	static const VALUE RUBY_T_COMPLEX  = 0x0e;
	static const VALUE RUBY_T_RATIONAL = 0x0f;

	static const VALUE RUBY_T_NIL    = 0x11;
	static const VALUE RUBY_T_TRUE   = 0x12;
	static const VALUE RUBY_T_FALSE  = 0x13;
	static const VALUE RUBY_T_SYMBOL = 0x14;
	static const VALUE RUBY_T_FIXNUM = 0x15;

	static const VALUE RUBY_T_UNDEF  = 0x1b;
	static const VALUE RUBY_T_NODE   = 0x1c;
	static const VALUE RUBY_T_ICLASS = 0x1d;
	static const VALUE RUBY_T_ZOMBIE = 0x1e;

	static const VALUE RUBY_T_MASK   = 0x1f;

	static const VALUE T_NONE		= RUBY_T_NONE;
	static const VALUE T_NIL		= RUBY_T_NIL;
	static const VALUE T_OBJECT		= RUBY_T_OBJECT;
	static const VALUE T_CLASS		= RUBY_T_CLASS;
	static const VALUE T_ICLASS		= RUBY_T_ICLASS;
	static const VALUE T_MODULE		= RUBY_T_MODULE;
	static const VALUE T_FLOAT		= RUBY_T_FLOAT;
	static const VALUE T_STRING		= RUBY_T_STRING;
	static const VALUE T_REGEXP		= RUBY_T_REGEXP;
	static const VALUE T_ARRAY		= RUBY_T_ARRAY;
	static const VALUE T_HASH		= RUBY_T_HASH;
	static const VALUE T_STRUCT		= RUBY_T_STRUCT;
	static const VALUE T_BIGNUM		= RUBY_T_BIGNUM;
	static const VALUE T_FILE		= RUBY_T_FILE;
	static const VALUE T_FIXNUM		= RUBY_T_FIXNUM;
	static const VALUE T_TRUE		= RUBY_T_TRUE;
	static const VALUE T_FALSE		= RUBY_T_FALSE;
	static const VALUE T_DATA		= RUBY_T_DATA;
	static const VALUE T_MATCH		= RUBY_T_MATCH;
	static const VALUE T_SYMBOL		= RUBY_T_SYMBOL;
	static const VALUE T_RATIONAL	= RUBY_T_RATIONAL;
	static const VALUE T_COMPLEX	= RUBY_T_COMPLEX;
	static const VALUE T_UNDEF		= RUBY_T_UNDEF;
	static const VALUE T_NODE		= RUBY_T_NODE;
	static const VALUE T_ZOMBIE		= RUBY_T_ZOMBIE;
	static const VALUE T_MASK		= RUBY_T_MASK;

	struct RBasic {
		VALUE flags;
		VALUE klass;
	};

	static inline struct RBasic* RBASIC(VALUE obj)	{ return (struct RBasic*)obj; }

	static const int RSTRING_EMBED_LEN_MAX = ((sizeof(VALUE)*3)/sizeof(char)-1);

	struct RString {
		struct RBasic basic;
		union {
			struct {
				long len;
				char *ptr;
				union {
					long capa;
					VALUE shared;
				} aux;
			} heap;
			char ary[RSTRING_EMBED_LEN_MAX + 1];
		} as;
	};

	static inline struct RString* RSTRING(VALUE obj)	{ return (struct RString*)obj; }

	static const VALUE RSTRING_NOEMBED			= FL_USER1;
	static const VALUE RSTRING_EMBED_LEN_MASK	= (FL_USER2|FL_USER3|FL_USER4|FL_USER5|FL_USER6);
	static const VALUE RSTRING_EMBED_LEN_SHIFT	= (FL_USHIFT+2);

	static inline char* RSTRING_PTR(VALUE str)
	{
		return (!(RBASIC(str)->flags & RSTRING_NOEMBED) ? RSTRING(str)->as.ary : RSTRING(str)->as.heap.ptr);
	}

	static inline long RSTRING_LEN(VALUE str)
	{
		return (!(RBASIC(str)->flags & RSTRING_NOEMBED) ? \
			(long)((RBASIC(str)->flags >> RSTRING_EMBED_LEN_SHIFT) & (RSTRING_EMBED_LEN_MASK >> RSTRING_EMBED_LEN_SHIFT)) : RSTRING(str)->as.heap.len);
	}

	static const int RARRAY_EMBED_LEN_MAX  = 3;

	struct RArray {
		struct RBasic basic;
		union {
			struct {
				long len;
				union {
					long capa;
					VALUE shared;
				} aux;
				VALUE *ptr;
			} heap;
			VALUE ary[RARRAY_EMBED_LEN_MAX];
		} as;
	};

	static inline struct RArray* RARRAY(VALUE obj)	{ return (struct RArray*)obj; }

	static const VALUE RARRAY_EMBED_FLAG		= FL_USER1;
	static const VALUE RARRAY_EMBED_LEN_MASK	= (FL_USER4|FL_USER3);
	static const VALUE RARRAY_EMBED_LEN_SHIFT	= (FL_USHIFT+3);

	static inline VALUE* RARRAY_PTR(VALUE ary)
	{
		return ((RBASIC(ary)->flags & RARRAY_EMBED_FLAG) ? RARRAY(ary)->as.ary : RARRAY(ary)->as.heap.ptr);
	}

	static inline long RARRAY_LEN(VALUE ary)
	{
		return ((RBASIC(ary)->flags & RARRAY_EMBED_FLAG) ? \
			(long)((RBASIC(ary)->flags >> RARRAY_EMBED_LEN_SHIFT) & (RARRAY_EMBED_LEN_MASK >> RARRAY_EMBED_LEN_SHIFT)) : RARRAY(ary)->as.heap.len);
	}

	struct RData {
		struct RBasic basic;
		void (*dmark)(void*);
		void (*dfree)(void*);
		void *data;
	};

	static inline struct RData* RDATA(VALUE obj)	{ return (struct RData*)obj; }
	static inline void* DATA_PTR(VALUE d)			{ return RDATA(d)->data; }

	static const VALUE	RUBY_IMMEDIATE_MASK			= 0x03;
	static inline bool	IMMEDIATE_P(VALUE x)		{ return (x & RUBY_IMMEDIATE_MASK) != 0; }

	static const VALUE	RUBY_SYMBOL_FLAG			= 0x0e;
	static const VALUE	RUBY_SPECIAL_SHIFT			= 8;
	static inline bool	SYMBOL_P(VALUE x)			{ return ((x&~(~(VALUE)0<<RUBY_SPECIAL_SHIFT))==RUBY_SYMBOL_FLAG); }

	static inline int	BUILTIN_TYPE(VALUE x)		{ return (int)(RBASIC(x)->flags & T_MASK); }

	static inline int	rb_type(VALUE obj)
	{
		if (IMMEDIATE_P(obj)) 
		{
			if (FIXNUM_P(obj))	return T_FIXNUM;
			if (obj == Qtrue)	return T_TRUE;
			if (SYMBOL_P(obj))	return T_SYMBOL;
			if (obj == Qundef)	return T_UNDEF;
		}
		else if (!RTEST(obj)) 
		{
			if (obj == Qnil)	return T_NIL;
			if (obj == Qfalse)	return T_FALSE;
		}
		return BUILTIN_TYPE(obj);
	}
	typedef long SIGNED_VALUE;

	static const VALUE RUBY_FIXNUM_FLAG	= 0x01;
	static const VALUE SYMBOL_FLAG = 0x0e;

	///<	类型转换
	static inline long FIX2LONG(VALUE x)			{ return (long)(((SIGNED_VALUE)x) >> 1); }
	static inline unsigned long FIX2ULONG(VALUE x)	{ return ((x >> 1) & LONG_MAX); }

	static inline int FIX2INT(VALUE x)				{ return (int)FIX2LONG(x); }
	static inline unsigned int FIX2UINT(VALUE x)	{ return (unsigned int)FIX2ULONG(x); }

	static inline VALUE INT2FIX(int i)				{ return ((VALUE)(((SIGNED_VALUE)(i)) << 1 | RUBY_FIXNUM_FLAG)); }

	static inline VALUE ID2SYM(ID id)				{ return (((VALUE)(id) << 8)| SYMBOL_FLAG); }

	static const unsigned long FIXNUM_MAX			= (unsigned long)(LONG_MAX >> 1);
	static const long FIXNUM_MIN					= ((long)LONG_MIN >> (int)1);

	static inline bool FIXNUM_P(VALUE f)			{ return (((SIGNED_VALUE)f) & RUBY_FIXNUM_FLAG) != 0; }
	static inline bool POSFIXABLE(unsigned long f)	{ return (f <= FIXNUM_MAX); }
	static inline bool NEGFIXABLE(long f)			{ return (f >= FIXNUM_MIN); }
	static inline bool FIXABLE(long f)				{ return (NEGFIXABLE(f) && (f <= 0 || POSFIXABLE(f))); }
#pragma endregion
#pragma region 导出Ruby
	static	const int addr_rb_funcall2=199424;
	static	const int addr_rb_define_class=386480;
	static	const int addr_rb_const_defined=425680;
	static	const int addr_rb_const_get=428048;
	static	const int addr_rb_intern=295376;
	static	const int addr_rb_intern2=345376;
	static	const int addr_rb_intern3=344080;
	static	const int addr_rb_fiber_start=532332;
	static	const int addr_rb_define_module=387072;
	static	const int addr_rb_define_module_function=389200;
	static	const int addr_rb_define_global_const=426224;
	static	const int addr_rb_define_global_function=426224;
	static	const int addr_rb_eval_string_protect=197152;
	static	const int addr_rb_id2name=653040;
	static	const int addr_rb_id2str=295536;
	static	const int addr_rb_scan_args=389616;
	static	const int addr_rb_class_new_instance=212016;
	static	const int addr_rb_define_method=388576;
	static	const int addr_rb_define_singleton_method=153456;
	static  const int addr_rb_str_new = 0x36290;
	static	const int addr_rb_define_const = 0x68070;
	static  const int addr_rb_str_new2 = 0x36340;
	static  const int addr_rb_string_value = 0x37A40;
	static  const int addr_rb_string_value_ptr = 0x37A70;
public:
	pfn_rb_funcall2 rb_funcall2;
	pfn_rb_define_class rb_define_class;
	pfn_rb_const_defined rb_const_defined;
	pfn_rb_const_get rb_const_get;
	pfn_rb_intern rb_intern;
	pfn_rb_define_module rb_define_module;
	pfn_rb_define_module_function rb_define_module_function;
	pfn_rb_define_global_const rb_define_global_const;
	pfn_rb_define_global_function rb_define_global_function;
	pfn_rb_eval_string_protect rb_eval_string_protect;;
	pfn_rb_id2name rb_id2name;
	pfn_rb_scan_args rb_scan_args;
	pfn_rb_class_new_instance rb_class_new_instance;
	pfn_rb_define_method rb_define_method;
	pfn_rb_str_new  rb_str_new ;
	pfn_rb_str_new2  rb_str_new2;
	pfn_rb_define_const rb_define_const;
	pfn_rb_string_value rb_string_value;
	pfn_rb_string_value_ptr rb_string_value_ptr;
#pragma endregion
};
extern RGSS3Runtime *sruntime;