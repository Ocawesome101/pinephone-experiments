// framebuffer: header file

char *fb;
char *buf;
int w, h;

int fb_init(lua_State* L);
int fb_set_pixel(lua_State* L);
int fb_fill_area(lua_State* L);
int fb_fill_screen(lua_State* L);
int fb_flip(lua_State* L);
