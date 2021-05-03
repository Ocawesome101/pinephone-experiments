// framebuffer

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>

#include "framebuffer.h"

void fb_init(fbo* new, const char* file, 
		unsigned int width, unsigned int height) {
	int fbdev = open(file, O_RDWR);

	if (fbdev == -1) {
		fprintf(stderr, "cannot open framebuffer: %s\n", file);
		exit(1);
	}

	char* ptr = (char *)mmap(0, (width * height * 4),
		PROT_READ | PROT_WRITE,
		MAP_SHARED, fbdev, 0);

	new->width = width;
	new->height = height;
	new->buf = ptr;
}

void fb_fill(fbo* fb, uint x, uint y, uint w, uint h, uint c) {
	uint i, j;
	for (i = 0; i < w; i++) {
		for (j = 0; j < h; j++) {
			*(pixptr(fb,x+i,y+j)) = c & 0xFF000000 >> 24;
			*(pixptr(fb,x+i,y+j)+1) = c & 0x00FF0000 >> 16;
			*(pixptr(fb,x+i,y+j)+2) = c & 0x0000FF00 >> 8;
		}
	}
}
