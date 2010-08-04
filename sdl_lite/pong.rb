def osx?
	PLATFORM =~/darwin/
end
if osx?
	require 'osx/cocoa'
	app = OSX::NSApplication.sharedApplication()
end
require 'display'
display = Display.new
display.clear_screen
display.init

def flip(display, pixel)
	for pos_y in (0..31)
		for pos_x in (0..63)
		end
	end
end
#creamos el muro
for i in (0..18)
	display.set_pixel 40, 5+i, 1
end

dx = 1
dy = 1
pos_x = 0
pos_y =rand(32)
for i in (0..550)
	dy = 1 if pos_y==0
	dy = -1 if pos_y==31 
	dx = 1 if pos_x==0
	dx = -1 if pos_x==63
	
	old_pos_x = pos_x
	old_pos_y = pos_y
	display.set_pixel pos_x, pos_y, 0
	pos_x += dx
	pos_y += dy
	
	#eval colision
	pixel = display.get_pixel pos_x, pos_y
	dx = -1 if pixel==1 
	display.set_pixel pos_x, pos_y, 1
	display.draw_screen	
	display.delay 15
	#display.set_pixel old_pos_x, old_pos_y , 0
end

