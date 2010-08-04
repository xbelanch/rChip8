#include <SDL.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <memory.h>
#include <ruby.h>

#define BOOL(x) (x)?Qtrue:Qfalse

static VALUE mDISPLAY;
SDL_Surface* display=NULL;
char screen[64*32];
int keys[16];
Uint8 white, black;


static
VALUE clear_screen(VALUE obj){
	int i, j;
	for (i=0; i<32; i++){
		for (j=0; j<64; j++){
			screen[i*64+j]=0x0;
		}
	}
	return Qnil;
}

static 
VALUE init(VALUE obj){
	int i;
	if (SDL_Init(SDL_INIT_VIDEO)== -1){
		printf("Can't Init SDL: %s\n", SDL_GetError());
		exit(1);
	}
	atexit(SDL_Quit);
	display = SDL_SetVideoMode(640,320,8, SDL_HWSURFACE);
	if (display == NULL){
		printf("Can't see video mode: %s\n", SDL_GetError());
		exit(1);
	}	
	white = SDL_MapRGB(display->format, 0x00, 0xFF, 0x00);
	black = SDL_MapRGB(display->format, 0x00, 0x00, 0x00);
	//init the keyboard
	for (i=0; i<16; i++){keys[i]=0;}
	return Qnil;
}

static VALUE
quit(VALUE self){
	SDL_Quit();
	return Qnil;
}

static
VALUE set_pixel(VALUE obj, VALUE x, VALUE y, VALUE v){
	screen[NUM2INT(y)*64+NUM2INT(x)]=NUM2INT(v);
	return Qnil;
}

static
VALUE get_pixel(VALUE obj, VALUE x, VALUE y){
	return INT2NUM(screen[NUM2INT(y)*64+NUM2INT(x)]);
}


static
VALUE delay(VALUE self, VALUE time_in_ns){
	//SDL_Delay(NUM2INT(time_in_ms));
	usleep(NUM2ULONG(time_in_ns));
	return Qnil;
}

static
VALUE get_ticks(VALUE self){
	return UINT2NUM(SDL_GetTicks());
}

static
VALUE draw_screen(VALUE obj){
	SDL_Rect rect;
	rect.x = 0;
	rect.y = 0;
	rect.w = 10;
	rect.h = 10;
	int i, j;
	for (i=0; i<32; i++){
		rect.y = i*10;
		for (j=0; j<64; j++){
			rect.x = j*10;
			if(screen[i*64+j]>0){
				SDL_FillRect(display,&rect,white);
			} else {
				SDL_FillRect(display,&rect,black);
			}
		}
	}
	SDL_Flip(display);
}	

void keyboard(){
	SDL_Event event;
	int key;
	int i;
	//SDL Events
	//
	while (SDL_PollEvent(&event)){
		if (event.type == SDL_QUIT ) { exit(0); }
		if ((event.type == SDL_KEYDOWN ) || (event.type == SDL_KEYUP)){
			key = event.key.keysym.sym;
			switch (key){
				case SDLK_ESCAPE:
					exit(0);
					break;
				case SDLK_1:
					keys[1]^=1;
					break;
				case SDLK_2:
					keys[2]^= 1;
					break;
				case SDLK_3:
					keys[3]^=1;
					break;
				case SDLK_4:
					keys[12]^=1;
					break;
				case SDLK_q:
					keys[4]^=1;
					break;
				case SDLK_e:
					keys[6]^=1;
					break;
				case SDLK_r:
					keys[13]^=1;
					break;
				case SDLK_w:
					keys[5]^=1;
					break;
				case SDLK_d:
					keys[9]^=1;
					break;
				case SDLK_x:
					keys[0]^=1;
					break;
				case SDLK_c:
					keys[11]^=1;
					break;
				case SDLK_z:
					keys[10]^=1;
					break;
				case SDLK_v:
					keys[15]^=1;
					break;
				default:
					//for (i= 0; i<15; i++){keys[i]=0;}
					break;
				}
		}
	}
}


static
VALUE get_key(VALUE obj, VALUE x){
	keyboard();
	//printf("key[%i]=%i\n",NUM2INT(x), keys[x]);
	return INT2NUM(keys[NUM2INT(x)]);
}

static
VALUE down_key(VALUE obj, VALUE x){
	keys[NUM2INT(x)]=0;
	return Qnil;
}
	

void Init_display(){
	mDISPLAY = rb_define_class("Display", rb_cObject);
	rb_define_method(mDISPLAY,"init",init,0);
	rb_define_method(mDISPLAY,"quit",quit,0);
	rb_define_method(mDISPLAY,"clear_screen",clear_screen,0);
	rb_define_method(mDISPLAY,"set_pixel",set_pixel,3);
	rb_define_method(mDISPLAY,"get_pixel",get_pixel,2);
	rb_define_method(mDISPLAY,"draw_screen",draw_screen,0);
	rb_define_method(mDISPLAY,"delay",delay,1);
	//rb_define_method(mDISPLAY,"keyboard",keyboard,0);
	rb_define_method(mDISPLAY,"get_key",get_key,1);
	rb_define_method(mDISPLAY,"down_key",down_key,1);
	rb_define_method(mDISPLAY,"get_ticks",get_ticks,0);
	
}
/*
static
VALUE t_put_pixel_at(VALUE obj, VALUE x, VALUE y, VALUE r, VALUE g, VALUE b){
	SDL_Surface *t_surface;
	Data_Get_Struct(obj,SDL_Surface,t_surface);
	Uint8 color;
	char* pData;
	color = SDL_MapRGB(t_surface->format, NUM2INT(r), NUM2INT(g) , NUM2INT(b));
	pData = (char*)t_surface->pixels;
	//vertical_offset
	pData += (NUM2INT(y)*t_surface->pitch);
	//horizonatl offset
	pData += (NUM2INT(x)*t_surface->format->BytesPerPixel);
	//copy from color
	memcpy(pData, &color, t_surface->format->BytesPerPixel);
	return Qnil;
}
*/
/*
 * Develop a getpixel value!!
 */
/*
static
VALUE t_get_pixel_at(VALUE obj, VALUE x, VALUE y){
	SDL_Surface *t_surface;
	Data_Get_Struct(obj,SDL_Surface,t_surface);
	Uint8* color;
	char* pData;
	color = SDL_MapRGB(t_surface->format, NUM2INT(r), NUM2INT(g) , NUM2INT(b));
	pData = (char*)t_surface->pixels;
	//vertical_offset
	pData += (NUM2INT(y)*t_surface->pitch);
	//horizonatl offset
	pData += (NUM2INT(x)*t_surface->format->BytesPerPixel);
	//copy from color
	memcpy(color, pData,  t_surface->format->BytesPerPixel);
	return INT2NUM(&color);
}
*/
