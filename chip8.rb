def osx?
	PLATFORM =~/darwin/
end
if osx?
	require 'osx/cocoa'
	app = OSX::NSApplication.sharedApplication()
end
require 'memory'
require 'sdl_lite/display'

class Chip8

	FRAMESTEP = 2
	INTERRUPTPERIOD = 30
	CYCLESxOPCODE = 5

	def initialize(rom)
		#@zoom = zoom
		@display = Display.new
		@display.clear_screen
		@display.init
		@memory = Memory.new(rom)
		@videomemory = [0]*64*32
		@pc = 0x200
		@ir = 0x200
		@delay = 0
		@sound = 0
		@iperiod = 0
		@sp = 0
		@stack = [0]*16
		@register = [0]*16
		@debug = true
		@run = true
		@frNTicks = 0
	end


	def print_registers
		if @debug
		@register.each_with_index do |reg,index|
			printf("V[%2x]: %2x | ", index, reg)
		end
		puts "\n"
		printf("####### @ir = 0x0%4x #########\n", @ir)
		end	
	end

	def quit
		@display.quit
	end

	def updateScreen
		#Update screen
		@display.draw_screen
		#Adjust frame rate
		@frame += 1
		if @frame % FRAMESTEP ==0
			delta = @display.get_ticks - @frNTicks
			#puts delta
			@display.delay((2500 * FRAMESTEP)-delta) if delta < (2500*FRAMESTEP)
			@frNTicks = @display.get_ticks
			@delay -=1 if @delay > 0
		end
		@frame = 0 if @frame%50==0
	end 
		
	def run()
		counter = INTERRUPTPERIOD
		@frNTicks = @display.get_ticks
		@frame = 0
		load("opcodes.rb")
		while @run
			counter -= CYCLESxOPCODE	
			opcode = (@memory[@pc]<<8)|@memory[@pc+1]
			fetchcode(opcode) 
			if counter <= 0
				#@delay -=1 if @delay > 0
				@sound -=1 if @sound > 0
				self.updateScreen
				counter += INTERRUPTPERIOD
			end
		end
	end
	
end

chip = Chip8.new(ARGV[0])
chip.run
chip.quit
