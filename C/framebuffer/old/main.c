#include <lua.h>
#include <lauxlib.h>

#include "framebuffer.h"

static luaL_Reg const framebufferlib[] = {
	{ "set_pixel", fb_set_pixel },
	{ "fill", fb_fill },
	{ "get_size", fb_get_size },
	{ "set_size", fb_set_size },
	{ NULL, NULL }
};

#ifndef FRAMEBUFFER_API
#define FRAMEBUFFER_API
#endif

FRAMEBUFFER_API int luaopen_framebuffer(lua_State* L) {
	fb_init();
	luaL_newlib(L, framebufferlib);
	return 1;
}
