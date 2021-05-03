// framebuffer

#ifndef fb_h
#define fb_h

typedef struct fb_struct {
  unsigned int width;
  unsigned int height;
  char* buf;
} fbo;

typedef unsigned int uint;

#define xy(x,y,w) (x*4)+(y*w*4)
#define pack_color(r,g,b) (b<<24)+(g<<16)+(r<<8)
#define pixptr(fb,x,y) fb->buf+xy(x,y,fb->width)

void fb_init(fbo* new, const char* file, uint width, uint height);
void fb_fill(fbo* fb, uint x, uint y, uint w, uint h, uint c);

#endif
