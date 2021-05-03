#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <lua.h>
#include <lauxlib.h>
#include "framebuffer.h"
#include "framebuffer.c"

static luaL_Reg const framebufferlib[] = {
	{ "init", fb_init },
	{ "set_pixel", fb_set_pixel },
	{ "fill_screen", fb_fill_screen },
	{ "fill_area", fb_fill_area },
	{ "flip", fb_flip },
	{ NULL, NULL }
};

int luaopen_framebuffer(lua_State* L) {
	luaL_newlib(L, framebufferlib);
	return 1;
}
