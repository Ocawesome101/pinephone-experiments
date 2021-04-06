// framebuffer library

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>

#ifndef FRAMEBUFFER_DEVICE
#define FRAMEBUFFER_DEVICE "/dev/fb0"
#endif

int fbdev;
char *fbp = 0;
lua_Integer fb_width, fb_height;

void fb_init() {
	fbdev = open(FRAMEBUFFER_DEVICE, O_RDWR);
	if (fbdev == -1) {
		fprintf(stderr, "cannot open framebuffer device\n");
		exit(1);
	}
	fb_width = 0;
	fb_height = 0;
}

int fb_write_raw(unsigned long seek_to, unsigned int color) {
	if (fbp == 0) {
		return -1;
	}
	if (seek_to > fb_width * fb_height * 4) {
		return 0;
	}
	int b = color & 0x0000FF;
	int g = (color >> 8) & 0x00FF00;
	int r = (color >> 16);
	*(fbp + seek_to) = b;
	*(fbp + seek_to + 1) = g;
	*(fbp + seek_to + 2) = r;
	*(fbp + seek_to + 3) = 0;
	return 0;
}

long int fb_get_coordinates(lua_Integer x, lua_Integer y) {
	x -= 1;
	//y -= 1;
	return (x * 4) + (y * fb_width * 4) - 4;
}

static int fb_set_size(lua_State* L) {
	fb_width = luaL_checkinteger(L, 1);
	fb_height = luaL_checkinteger(L, 2);
	// TODO: we may need to unmap this through ex. fb_deinit()
	// TODO: this WILL NOT WORK with color depths != 32 bit BRGT
	fbp = (char *)mmap(0, (fb_width * fb_height * 4),
		PROT_READ | PROT_WRITE, MAP_SHARED, fbdev, 0);
	return 0;
}

static int fb_set_pixel(lua_State* L) {
	lua_Integer x = luaL_checkinteger(L, 1);
	lua_Integer y = luaL_checkinteger(L, 2);
	lua_Integer color = luaL_checkinteger(L, 3);
	long seek_to = fb_get_coordinates(x, y);
	fb_write_raw(seek_to, color);
	return 0;
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
	return 0;
}

static int fb_get_size(lua_State* L) {
	lua_pushinteger(L, fb_width);
	lua_pushinteger(L, fb_height);
	return 2;
}
