#include <stdio.h>
#include "framebuffer.h"
#include "framebuffer.c"

int main() {
	fbo fbo;
	printf("init\n");
	fb_init(&fbo, "/dev/fb0", 720, 1440);
	printf("clear: %x\n", pack_color(0x00, 0xAA, 0xFF));
	fb_fill(&fbo, 0, 0, 719, 1439, pack_color(0x00, 0xaa, 0xff));
	printf("fill\n");
	fb_fill(&fbo, 100, 100, 200, 200, pack_color(0xff, 0xff, 0x00));
}
