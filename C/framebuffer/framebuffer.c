// framebuffer.c

#define getarg luaL_checkinteger
#define li lua_Integer
#define getpos(X,Y) (X*4)+(Y*w*4)-4

int fb_init(lua_State* L) {
	w = getarg(L, 1);
	h = getarg(L, 2);
	int fbdev = open("/dev/fb0", O_RDWR);

	if (fbdev == -1) {
		fprintf(stderr, "cannot open framebuffer\n");
		exit(1);
	}

	// buffer allocation
	fb = (char *)mmap(0, (w * h * 4),
			PROT_READ | PROT_WRITE,
			MAP_SHARED, fbdev, 0);

	buf = (char *)malloc(w * h * 4);

	return 0;
}

// Copy the offscreen buffer to the screen.
int fb_flip(lua_State* L) {
	int i;
	for (i = 0; i < w * h * 4; i++) {
		*(fb + i) = *(buf + i);
	}
	return 0;
}

// Set pixel at [x, y] to [color].
int fb_set_pixel(lua_State* L) {
	li x = getarg(L, 1);
	li y = getarg(L, 2);
	int color = getarg(L, 3);
	char r = *((char*)(&color));
	char g = *((char*)(&color) + 1);
	char b = *((char*)(&color) + 2);
	int pos = getpos(x, y);
	*(buf + pos) = b;
	*(buf + pos + 1) = g;
	*(buf + pos + 2) = r;
	return 0;
}

// Fill a screen area.
int fb_fill_area(lua_State* L) {
	li x = getarg(L, 1);
	li y = getarg(L, 2);
	li wd = getarg(L, 3);
	li ht = getarg(L, 4);
	int color = getarg(L, 3);
	char r = *((char*)(&color));
	char g = *((char*)(&color) + 1);
	char b = *((char*)(&color) + 2);
	int i, j;
	for (i = 0; i < wd; i++) {
		for (j = 0; j < ht; j++) {
  		int pos = getpos(x + i, y + j);
		  *(buf + pos) = b;
		  *(buf + pos + 1) = g;
		  *(buf + pos + 2) = r;
		}
	}
	return 0;
}

int fb_fill_screen(lua_State* L) {
	int color = getarg(L, 1);
  char r = *((char*)(&color));
  char g = *((char*)(&color) + 1);
  char b = *((char*)(&color) + 2);
	int x = 1;
	int y = 0;
	int i, j;
  for (i = 0; i < w; i++) {
    for (j = 0; j < h; j++) {
      int pos = getpos(x + i, y + j);
			//printf("%p / %p / %p\n", buf, pos, buf + pos);
      *(buf + pos) = b;
      *(buf + pos + 1) = g;
      *(buf + pos + 2) = r;
    }
  }
	return 0;
}
