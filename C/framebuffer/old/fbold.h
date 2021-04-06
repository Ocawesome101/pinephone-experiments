// framebuffer library

#include <stdio.h>
#include <stdlib.h>

#ifndef FRAMEBUFFER_DEVICE
#define FRAMEBUFFER_DEVICE "/dev/fb0"
#endif

FILE* fbdev;
unsigned long fcpos;
lua_Integer fb_width, fb_height;

void fb_init() {
	fbdev = fopen(FRAMEBUFFER_DEVICE, "w");
	if (fbdev == -1) {
		fprintf(stderr, "cannot open framebuffer device\n");
		exit(1);
	}
	fb_width = 0;
	fb_height = 0;
	fcpos = 0;
}

void fb_write_raw(unsigned long seek_to, unsigned int color) {
	if (seek_to != fcpos) {
		fseek(fbdev, seek_to, 0);
		fcpos = seek_to + 4;
	}
	int b = color & 0x0000FF;
	int g = (color >> 8) & 0x00FF00;
	int r = (color >> 16);
	fputc(b, fbdev);
	fputc(g, fbdev);
	fputc(r, fbdev);
	fputc(0, fbdev);
}

long int fb_get_coordinates(lua_Integer x, lua_Integer y) {
	return (x * 4) + (y * fb_width * 4) - 4;
}

static int fb_set_size(lua_State* L) {
	fb_width = luaL_checkinteger(L, 1);
	fb_height = luaL_checkinteger(L, 2);
	return 1;
}

static int fb_set_pixel(lua_State* L) {
	lua_Integer x = luaL_checkinteger(L, 1);
	lua_Integer y = luaL_checkinteger(L, 2);
	lua_Integer color = luaL_checkinteger(L, 3);
	long seek_to = fb_get_coordinates(x, y);
	fb_write_raw(seek_to, color);
	fflush(fbdev);
	return 1;
}

static int fb_fill(lua_State* L) {
	lua_Integer x = luaL_checkinteger(L, 1);
	lua_Integer y = luaL_checkinteger(L, 2);
	lua_Integer w = luaL_checkinteger(L, 3);
	lua_Integer h = luaL_checkinteger(L, 4);
	lua_Integer color = luaL_checkinteger(L, 5);
	long seek_to;
	for (int i = 0; i < h; i++) {
		for (int n = 0; n < w; n++) {
			seek_to = fb_get_coordinates(x + n, y + i);
			fb_write_raw(seek_to, color);
		}
	}
	fflush(fbdev);
	return 1;
}

static int fb_get_size(lua_State* L) {
	lua_pushinteger(L, fb_width);
	lua_pushinteger(L, fb_height);
	return 1;
}
