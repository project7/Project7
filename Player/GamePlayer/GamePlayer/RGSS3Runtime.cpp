#include "RGSS3Runtime.h"
RGSS3Runtime::RGSS3Runtime(GamePlayer * gp)
{
	//FILE *f=fopen("test.log","w");
	module=gp->hRgssCore;
	//fprintf(f,"Module:%d\n",module);
	assert(module);
#define __sf( fc ) fc = (pfn_##fc)((DWORD)addr_##fc+(DWORD)module);\
	assert(fc );
	__sf(rb_funcall2)
	__sf(rb_define_class)
	__sf(rb_const_defined)
	__sf(rb_const_get)
	__sf(rb_intern)
	__sf(rb_define_module)
	__sf(rb_define_module_function)
	__sf(rb_define_global_const)
	__sf(rb_define_global_function)
	__sf(rb_eval_string_protect)
	__sf(rb_id2name)
	__sf(rb_scan_args)
	__sf(rb_class_new_instance)
	__sf(rb_define_method)
	__sf(rb_str_new)
	__sf(rb_str_new2)
	__sf(rb_define_const)
	__sf(rb_string_value)
	__sf(rb_string_value_ptr)
	__sf(rb_raise)
	__sf(rb_obj_is_kind_of)
	__sf(rb_obj_classname)
	__sf(rb_ary_new)
	__sf(rb_ary_push)
	//fclose(f);
#undef __sf
	rmGraphics = *(DWORD *)(((DWORD)module+(DWORD)0x25EB00));
}
RGSS3Runtime *sruntime;