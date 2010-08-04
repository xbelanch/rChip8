require 'mkmf'
if have_library("SDL")
	sdl_config = with_config('sdl-config', 'sdl-config')
   	$CFLAGS += ' ' + `#{sdl_config} --cflags`.chomp
end
create_makefile("display")
