# Chip-8 has 35 opcodes, which are all two bytes long:
# http://en.wikipedia.org/wiki/CHIP-8
# http://members.aol.com/autismuk/chip8/chip8def.htm
# nnn: address
# nn: 8-bit constant
# N: 4 bit constant
# X and Y registers
# 
def pdebug(string, opcode)
  printf("pc: %4x\t#{string}\t\topcode: %4x\n",@pc, opcode) 
  printf("####### @ir = 0x0%4x #########\n", @ir)
end

def fetchcode(opcode)
	#add 2 to program counter
	@pc += 2
  puts "opcode to fecth: %4x\n" % opcode if @debug
  nnn = opcode & 0x0FFF
  nn  = opcode & 0x00FF
  n   = opcode & 0x000F
  x   = (opcode & 0x0F00)>>8
  y   = (opcode & 0x00F0)>>4
  #clear the screen
  if opcode==0xe0
    pdebug("Clear the screen", opcode) if @debug
    @display.clear_screen
  end
  #returns from a subroutine
  if opcode==0xee
    pdebug("Returns from a subroutine", opcode) if @debug
	#	@sp -=1
    @pc = (@stack.pop)
  end
  case (opcode & 0xF000)>>12
  when 1
    #Jumps to address nnn.
    pdebug("Jumps to address: #{nnn}",opcode) if @debug
    @pc = nnn
  when 2
    #Calls subroutine at nnn.
    pdebug("Calls subroutine at #{nnn}", opcode) if @debug
    @stack.push(@pc)
    @pc = nnn
  when 3
    #Skips the next instruction if VX equals nn.
    pdebug("Skips the next instruction if register[#{x}] equals #{nn}.", opcode) if @debug
		@pc +=2 if @register[x] == nn
  when 4
    #Skips the next instruction if VX doesn't equal nn.
    pdebug("Skips the next instruction if register[#{x}] doesnt equals #{nn}.", opcode) if @debug
    @pc +=2 if @register[x] != nn
  when 5
    #Skips the next instruction if VX equals VY. 
    pdebug("Skips the next instruction if register[#{x}] equals register[#{y}}.", opcode) if @debug
    @pc +=2 if @register[x] == @register[y]
  when 6
    #Sets VX to nn.
    pdebug("Set register[#{x}] to #{nn}",opcode) if @debug
    @register[x] = nn
  when 7
    #Adds nn to VX.
    pdebug("Adds #{nn} to @register[#{x}]",opcode) if @debug
    @register[x] += nn
		#We dont set the carry reg, but fails in games like INVADERS if not exist
		@register[x] = ((@register[x]>>8)<<8)^@register[x] if @register[x]>255 	
  when 8
    case n
      when 0
      #Sets VX to the value of VY.
      pdebug("Sets V[#{x}] to the value of V[#{y}]", opcode) if @debug	
      @register[x]=@register[y]
      when 1
      #Sets VX to VX or VY. 
      pdebug("Sets V[#{x}] to V[#{x}] OR V[#{y}]", opcode) if @debug	
      @register[x] |= @register[y]
      when 2
      #Sets VX to VX and VY. 
      pdebug("Sets V[#{x}] to V[#{x}] AND V[#{y}]", opcode) if @debug	
      @register[x] &= @register[y]
      when 3
      #Sets VX to VX xor VY. 
      pdebug("Sets V[#{x}] to V[#{x}] XOR V[#{y}]", opcode) if @debug	
      @register[x] ^= @register[y]
      when 4
      #Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't
      pdebug("Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't.",opcode) if @debug
      @register[x] += @register[y]
      if @register[x] >255
				@register[0xf] = 1 #set carry to 1
				#We dont set the carry reg, but fails in games like INVADERS if not exist
				#@register[x] = ((@register[x]>>8)<<8)^@register[x] 
				@register[x] &= 0xFF;
      else
				@register[0xf] = 0 #set carry to 0
      end
      when 5
      #VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
      pdebug("VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.", opcode) if @debug
      #if @register[x] < @register[y]
      if @register[x] >= @register[y]
				@register[0xf] = 1 #there's a borrrow
				#We dont set the carry reg, but fails in games like INVADERS if not exist
      else
				@register[0xf] = 0 #there's no borrrow
      end
      @register[x] -= @register[y]
	  @register[x] &= 0xFF
      when 6
      #Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift. [1]
      pdebug("Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift.", opcode) if @debug
	 @register[0xf] = @register[x] & 0x1
      @register[x] >>=1
	when 7
		if @register[y] >= @register[x]
			@register[0xf]=1
		else
			@register[0xf]=0
		end
			#reverse substract register!
			@register[x]=@register[y]-@register[x]
			@register[x] &=0xFF
			when 0xe
			#shift register left
			@register[0xf] = (@register[x] & 0x80)>>7
			@register[x] <<=1
			@register[x] &=0xFF
			
  end #end of case when 8...
  when 9
    #Skips the next instruction if VX doesn't equal VY.
    pdebug("Skips the next instruction if VX doesn't equal VY.", opcode) if @debug
		@pc +=2 if @register[x] != @register[y]
  when 0xA
    #Sets I to the address NNN.
    pdebug("Sets I to the address #{nnn}", opcode) if @debug
    @ir = nnn
  when 0xB
    #Jumps to the address NNN plus V0.
    pdebug("Jumps to the address NNN plus V0.", opcode) if @debug
    @pc = nnn + @register[0]
  when 0xC
    #Sets VX to a random number and NN.
    pdebug("Sets V[#{x}] to a random number (#{rand(255)})and #{nn}.", opcode) if @debug
    @register[x]= rand(255) & nn
  when 0xD
    #Draws a sprite at coordinate (VX, VY) that has a width of 8 pixels and a height of N pixels. As described above, VF is set to 1 if any screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that doesn't happen.
    pdebug("Draws a sprite at coordinate (V[#{x}]=#{@register[x]}, V[#{y}]=#{@register[y]}) that has a width of 8 pixels and a height of #{n} pixels.", opcode) if @debug
    #self.sprite_at @register[x], @register[y], n
    @register[0xf]=0
	pos_x = @register[x]
	pos_y = @register[y]
	for i in (0..n-1)	
		line = @memory[@ir+i]
		for j in (0..7)
			if (line & (0x80 >> j)) !=0
				pixel = @display.get_pixel pos_x+j, pos_y+i
				@register[0xf]=1 if pixel == 1
				#the xor mode!!
				@display.set_pixel pos_x+j, pos_y+i, pixel^=1
			end
		end
	end		
	#@display.draw_screen
  when 0xE
    if nn==0x9e
      #Skips the next instruction if the key stored in VX is pressed.
      pdebug("Skips the next instruction if the key stored in V[#{x}]=#{@register[x]} is pressed.", opcode) if @debug
      @pc+=2 if @display.get_key(@register[x])== 1
    end
    if nn==0xa1
    #Skips the next instruction if the key stored in VX isn't pressed.
      pdebug("Skips the next instruction if the key stored in V[#{x}]=#{@register[x]} isn't pressed.", opcode) if @debug
	@pc += 2 if @display.get_key(@register[x])==0
    end
  when 0xF
    if nn==0x07
    #Sets VX to the value of the delay timer.
      pdebug("Sets VX to the value of the delay timer.", opcode) if @debug
      @register[x]= @delay 
    end
    if nn==0x0a
    #A key press is awaited, and then stored in VX.
      pdebug("A key press is awaited, and then stored in V[#{x}]=#{@register[x]}.", opcode) if @debug
      if @display.get_key(1) != 0
	      @register[x]=@display.get_key(x)
      else
	      @pc -= 2
      end
    end
    if nn==0x15
    #Sets the delay timer to VX.
      pdebug("Sets the delay timer to VX.", opcode) if @debug
       @delay=@register[x] 
    end
    if nn==0x18
    #Sets the sound timer to VX.
      pdebug("Sets the sound timer to VX.", opcode) if @debug
      @sound= @register[x] 
    end
    if nn==0x1E
    #Adds VX to I.
      pdebug("Adds VX to I.", opcode) if @debug
      @ir += @register[x]
    end
    if nn==0x29
    #Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font.
      pdebug("Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font.", opcode) if @debug
      @ir = @register[x]*5
    end
    if nn==0x33
    #Stores the Binary-coded decimal representation of VX at the addresses I, I plus 1, and I plus 2.
      pdebug("Stores the Binary-coded decimal representation of VX at the addresses I, I plus 1, and I plus 2.", opcode) if @debug
      @memory[@ir+0]= @register[x]/100
      @memory[@ir+1]= (@register[x]/10) % 10
      @memory[@ir+2]= @register[x] % 10
    end
    if nn==0x55
    #Stores V0 to VX in memory starting at address I.
      pdebug("Stores V0 to VX in memory starting at address I.", opcode) if @debug
			for i in (0..x)
				@memory[@ir]=@register[i]
				@ir += 1
			end
    end
    if nn==0x65
    #Fills V0 to VX with values from memory starting at address I. [2]
      pdebug("Fills V0 to VX with values from memory starting at address I.", opcode) if @debug
			for i in (0..x)
				@register[i] = @memory[@ir]
				@ir +=1
			end
    end
      
  end
end

