##################################################################### 
# 
# CSC258H Winter 2021 Assembly Final Project 
# University of Toronto, St. George 
# 
# Student: Jonathan Lam, 1006186627
# 
# Bitmap Display Configuration: 
# - Unit width in pixels: 8    
# - Unit height in pixels: 8 
# - Display width in pixels: 256 
# - Display height in pixels: 256 
# - Base Address for Display: 0x10008000 ($gp) 
# 
# Which milestone is reached in this submission? 
# (See the project handout for descriptions of the milestones) 
# - Milestone 3
# 
# Which approved additional features have been implemented? 
# (See the project handout for the list of additional features) 
# N/A
# 
# Any additional information that the TA needs to know: 
# - I noticed that the game was really easy to win so I made it a little harder by limiting some features
# - Also for maximal FPS and game run play after restarting computer with no other applications open
#	The game can really lag if you play when your cpu has been on for a while or if you have a lot of apps open
#
####################################################################

.data
	displayAddress:	.word 0x10008000
	bugLocation: .word 1006
	lazer: .word 974
	flea: .word 0, 0
	centipedLocation: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	centipedDirection: .word 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	mushrooms: .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	health: .word 3
	winMessage: .asciiz "You won! Press 's' to retry.\n"
	loseMessage: .asciiz "You lost! Press 's' to retry.\n"
	restart: .word 0
.text 
rest:
	jal init_mushrooms
Loop:
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	addi $sp, $sp, -4
	sw $t4, 0($sp)
	addi $sp, $sp, -4
	sw $t5, 0($sp)
	addi $sp, $sp, -4
	sw $t6, 0($sp)
	addi $sp, $sp, -4
	sw $t7, 0($sp)
	
	jal create_mushrooms
	jal make_black
	jal disp_centiped
	jal delay
	jal check_keystroke
	jal check_collision
	jal flea_init
	
	jal flea_move

	lw $t7, 0($sp)
	addi $sp, $sp, 4
	lw $t6, 0($sp)
	addi $sp, $sp, 4
	lw $t5, 0($sp)
	addi $sp, $sp, 4
	lw $t4, 0($sp)
	addi $sp, $sp, 4
	lw $t3, 0($sp)
	addi $sp, $sp, 4
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	
	j res
	#j Loop	

Exit:
	li $v0, 10		# terminate the program gracefully
	syscall

init_mushrooms:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $t0, $zero, 25
	la $t1, mushrooms
	
mush_loop_init:
	#Loads a random number from 0 to 928 (stores in a0)
	addi $a1, $zero, 896
	addi, $v0, $zero, 42
	syscall
	
	#lw $t2, 0($t1)
	lw $t3, displayAddress
	li $t4, 0x9966ff
	
	addi $t6, $a0, 11 	#add 11 to make sure mushroom doesnt spawn where centi spawns
	
	sll $t5,$t6, 2		# $t4 is the bias of the old body location in memory (offset*4)
	add $t5, $t3, $t5	# $t4 is the address of the old bug location
	sw $t4, 0($t5)
	
		
	sw $t6, 0($t1) 		#Save new location of mushroom in array
	
	addi $t0, $t0, -1
	addi $t1, $t1, 4
	bne $t0, 0, mush_loop_init
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

create_mushrooms:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	#li $v0, 1
	#lw $a0, health
	#syscall

	addi $t0, $zero, 25
	la $t1, mushrooms
mush_loop:
	
	lw $t2, 0($t1)
	
	beq $t2, 0, skip_disp_mush
	
	lw $t3, displayAddress
	li $t4, 0x9966ff
	
	sll $t5,$t2, 2		# $t4 is the bias of the old body location in memory (offset*4)
	add $t5, $t3, $t5	# $t4 is the address of the old bug location
	sw $t4, 0($t5)
	
	sw $t2, 0($t1)
	
skip_disp_mush:
	addi $t0, $t0, -1
	addi $t1, $t1, 4
	bne $t0, 0, mush_loop


	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
make_black:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a1, centipedLocation
	lw $t1, 0($a1)
	lw $t2, displayAddress 
	li $t3, 0x000000
	sll $t4,$t1, 2		# $t4 is the bias of the old body location in memory (offset*4)
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	sw $t3, 0($t4)
	
	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
# function to display a static centiped	
disp_centiped:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)


	addi $a3, $zero, 10	 # load a3 with the loop count (10)
	la $a1, centipedLocation # load the address of the array into $a1
	la $a2, centipedDirection # load the address of the array into $a2
	

arr_loop:
	#iterate over the loops elements to draw each body in the centiped
	lw $t1, 0($a1)		 # load a word from the centipedLocation array into $t1
	lw $t5, 0($a2)		 # load a word from the centipedDirection  array into $t5
	la $t6, mushrooms
	
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	addi $s0, $zero, 25
	#####
	
	lw $t2, displayAddress 
	beq $a3, 10, skip # $t2 stores the base address for display
	#beq $a3, 1, head
	li $t3, 0xff0000	# $t3 stores the red colour code

	sll $t4,$t1, 2		# $t4 is the bias of the old body location in memory (offset*4)
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	sw $t3, 0($t4)		# paint the body with red
	
skip:
	beq $t1, 32, DOWN
	beq $t1, 96, DOWN
	beq $t1, 160, DOWN
	beq $t1, 224, DOWN
	beq $t1, 288, DOWN
	beq $t1, 352, DOWN
	beq $t1, 416, DOWN
	beq $t1, 480, DOWN
	beq $t1, 544, DOWN
	beq $t1, 608, DOWN
	beq $t1, 672, DOWN
	beq $t1, 736, DOWN
	beq $t1, 800, DOWN
	beq $t1, 864, DOWN
	beq $t1, 928, DOWN
	beq $t1, 992, DOWN
	
	beq $t1, 31, DOWN
	beq $t1, 95, DOWN
	beq $t1, 159, DOWN
	beq $t1, 223, DOWN
	beq $t1, 287, DOWN
	beq $t1, 351, DOWN
	beq $t1, 415, DOWN
	beq $t1, 479, DOWN
	beq $t1, 543, DOWN
	beq $t1, 607, DOWN
	beq $t1, 671, DOWN
	beq $t1, 735, DOWN
	beq $t1, 799, DOWN
	beq $t1, 863, DOWN
	beq $t1, 927, DOWN
	beq $t1, 991, DOWN
	
	
check_mush:	
	lw $t7, 0($t6)
	addi $sp, $sp, -4
	sw $s1, 0($sp)
	addi $sp, $sp, -4
	sw $s2, 0($sp)
	
	addi $s1, $t7, 1
	addi $s2, $t7, -1
	beq $t5, 1, check_pos_mush
	beq $t1, $s1, DOWN_MUSH
	j check_loop
	
check_pos_mush:	
	beq $t1, $s2, DOWN_MUSH 
	
check_loop:
	sw $t7, 0($t6)
	addi $t6, $t6, 4
	addi $s0, $s0, -1	
	
	lw $s2, 0($sp)
	addi $sp, $sp, 4
	lw $s1, 0($sp)
	addi $sp, $sp, 4
	bne $s0, $zero, check_mush
	
	beq $t5, 1, POS 
	subi $t1, $t1, 1 #move in negative position
	j END
DOWN:	
	addi $t1, $t1, 32 #move down 1
	beq $t5, 1, CH_POS #change Direction
	addi $t5, $t5, 2
	j END
POS:	#moving in postive direction
	addi $t1, $t1, 1 #move in pos
	j END
CH_POS:
	addi $t5, $t5, -2
	j END
	
DOWN_MUSH:	
	addi $t1, $t1, 32 #move down 1
	beq $t5, 1, CH_POS_MUSH #change Direction
	addi $t5, $t5, 2
	lw $s2, 0($sp)
	addi $sp, $sp, 4
	lw $s1, 0($sp)
	addi $sp, $sp, 4
	j END
CH_POS_MUSH:
	addi $t5, $t5, -2
	lw $s2, 0($sp)
	addi $sp, $sp, 4
	lw $s1, 0($sp)
	addi $sp, $sp, 4

END:
	sw $t1, 0($a1)
	sw $t5, 0($a2)
	beq $a3, 1, head
	li $t3, 0xff0000	# $t3 stores the red colour code
	j color
head:
	li $t3, 0x996600
color:
	sll $t4,$t1, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)
	
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	addi $a1, $a1, 4	 # increment $a1 by one, to point to the next element in the array
	addi $a2, $a2, 4
	addi $t6, $t6, -100
	addi $a3, $a3, -1	 # decrement $a3 by 1
	bne $a3, $zero, arr_loop
	
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

# function to detect any keystroke
check_keystroke:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	
	lw $t8, 0xffff0000
	beq $t8, 1, get_keyboard_input # if key is pressed, jump to get this key
	addi $t8, $zero, 0
	
	
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
# function to get the input key
get_keyboard_input:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t2, 0xffff0004
	addi $v0, $zero, 0	#default case
	beq $t2, 0x6A, respond_to_j
	beq $t2, 0x6B, respond_to_k
	beq $t2, 0x78, respond_to_x
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
# Call back function of j key
respond_to_j:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	addi $sp, $sp, -4
	sw $s1, 0($sp)
	
	la $t0, bugLocation	# load the address of buglocation from memory
	lw $t1, 0($t0)		# load the bug location itself in t1
	
	la $s0, lazer	# load the address of lazer from memory
	lw $s1, 0($s0)		# load the lazer location itself in s1
	
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0x000000	# $t3 stores the black colour code
	
	sll $t4,$t1, 2		# $t4 the bias of the old buglocation
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	sw $t3, 0($t4)		# paint the first (top-left) unit white.
	
	sll $s4, $s1, 2
	add $s4, $t2, $s4
	sw $t3, 0($s4)
	
	beq $t1, 992, skip_movement # prevent the bug from getting out of the canvas
	addi $t1, $t1, -1	# move the bug one location to the right
	addi $s1, $s1, -1
skip_movement:
	sw $t1, 0($t0)		# save the bug location
	sw $s1, 0($s0)

	li $t3, 0xffffff	# $t3 stores the white colour code
	li $s3, 0x00ffff
	
	sll $t4,$t1, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)		# paint the first (top-left) unit white.
	
	sll $s4, $s1, 2
	add $s4, $t2, $s4
	sw $s3, 0($s4)
	
	lw $s1, 0($sp)
	addi $sp, $sp, 4
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

# Call back function of k key
respond_to_k:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	addi $sp, $sp, -4
	sw $s1, 0($sp)
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	addi $sp, $sp, -4
	sw $s4, 0($sp)

	
	la $t0, bugLocation	# load the address of buglocation from memory
	lw $t1, 0($t0)		# load the bug location itself in t1
	
	la $s0, lazer	# load the address of lazer from memory
	lw $s1, 0($s0)		# load the lazer location itself in s1
	
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0x000000	# $t3 stores the black colour code
	
	sll $t4,$t1, 2		# $t4 the bias of the old buglocation
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	sw $t3, 0($t4)		# paint the block with black
	
	sll $s4, $s1, 2
	add $s4, $t2, $s4
	sw $t3, 0($s4)
	
	beq $t1, 1023, skip_movement2 #prevent the bug from getting out of the canvas
	addi $t1, $t1, 1
	addi $s1, $s1, 1	# move the bug one location to the right
skip_movement2:
	sw $t1, 0($t0)		# save the bug location
	sw $s1, 0($s0)

	li $t3, 0xffffff	# $t3 stores the white colour code
	li $s3, 0x00ffff
	
	sll $t4,$t1, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)		# paint the block with white
	
	sll $s4, $s1, 2
	add $s4, $t2, $s4
	sw $s3, 0($s4)
	
	lw $s4, 0($sp)
	addi $sp, $sp, 4
	lw $s3, 0($sp)
	addi $sp, $sp, 4

	lw $s1, 0($sp)
	addi $sp, $sp, 4
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
respond_to_x:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	addi $sp, $sp, -4
	sw $s1, 0($sp)
	addi $sp, $sp, -4
	sw $s2, 0($sp)
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	addi $sp, $sp, -4
	sw $s4, 0($sp)
	addi $sp, $sp, -4
	sw $s5, 0($sp)
	addi $sp, $sp, -4
	sw $s6, 0($sp)
	addi $sp, $sp, -4
	sw $s7, 0($sp)
	
	
	la $t0, lazer	# load the address of buglocation from memory
	lw $s3, 0($t0)
	addi $s0, $zero, 31
laz_rep:
	lw $t1, 0($t0)		# load the bug location itself in t1
	
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0x000000	# $t3 stores the black colour code
	
	sll $t4,$t1, 2		# $t4 the bias of the old buglocation
	add $t4, $t2, $t4	# $t4 is the addre of the old bug location
	sw $t3, 0($t4)		# paint the block with black
	
	
	subi $t1, $t1, 32	# move the bug one location up
	
	la $a1, centipedLocation
	addi $s5, $zero, 10
check_hit:	
	lw $s4, 0($a1)
	beq $s4, $t1, hit
	addi $a1, $a1, 4
	addi $s5, $s5, -1
	
	bne $s5, 0, check_hit 
	j check_mushrooms
	

hit: 
	addi $s0, $zero, 1
	la $s6, health
	lw $s7, 0($s6)
	addi $s7, $s7, -1	
	beq $s7, 0, win
	sw $s7, 0($s6)
	j check_last
	

check_mushrooms:
	la $a2, mushrooms
	addi $s5, $zero, 25
check_mush_hit:
	lw $s4, 0($a2)
	beq $s4, $t1, mush_hit
	addi $a2, $a2, 4
	addi $s5, $s5, -1
	
	bne $s5, 0, check_mush_hit
	j check_flea_hit
	
mush_hit:
	sll $t4,$s4, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)	
	
	addi $s0, $zero, 1
	addi $s4, $zero, 0
	sw $s4, 0($a2)
	j check_last

	
check_flea_hit:	
	la $a3, flea	#When we hit the flea	
	lw $s4, 0($a3)
	beq $s4, $t1, flea_hit
	j check_last
	
flea_hit:
	sll $t4,$s4, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)	
	
	addi $s0, $zero, 1
	addi $s4, $zero, 0
	sw $s4, 0($a3)
	sw $s4, 4($a3)

check_last:
	beq $s0, 1 , last_laz
	j not_last
last_laz:
	add $t1, $zero, $s3
not_last:	

	sw $t1, 0($t0)		# save the bug location

	li $t3, 0x00ffff	# $t3 stores the cyan colour code
	
	sll $t4,$t1, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)		# pa$t4int the block with cyan
	
	
	
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	
	addi $sp, $sp, -4
	sw $t4, 0($sp)
	
	beq $s0, 30, update	#When how often to repaint when we shoot the lazer
	beq $s0, 20, update
	beq $s0, 10, update
	j skip_update
	
update:	
	jal make_black
	jal disp_centiped
	jal flea_init
	jal flea_move
	jal create_mushrooms

skip_update:
	lw $t4, 0($sp)
	addi $sp, $sp, 4
	
	lw $t3, 0($sp)
	addi $sp, $sp, 4
	
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	addi $sp, $sp, 4
		
	addi $s0, $s0, -1
	addi $s1, $zero, 3000
delay_loop2:
	addi $s1, $s1, -1
	bgtz $s1, delay_loop2
	bne $s0, 0, laz_rep
	
	sw $t1, 0($t0)
	
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	lw $s1, 0($sp)
	addi $sp, $sp, 4
	lw $s2, 0($sp)
	addi $sp, $sp, 4
	lw $s3, 0($sp)
	addi $sp, $sp, 4
	lw $s4, 0($sp)
	addi $sp, $sp, 4
	lw $s5, 0($sp)
	addi $sp, $sp, 4
	lw $s6, 0($sp)
	addi $sp, $sp, 4
	lw $s7, 0($sp)
	addi $sp, $sp, 4
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
	
flea_init:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, flea
	
	bne $t0, 0, skip_flea
	
	addi $a1, $zero, 11
	addi, $v0, $zero, 42
	syscall
	
	bne $a0, 10, skip_flea
	
	addi $a1, $zero, 32
	addi, $v0, $zero, 42
	syscall
	
	
	
	add $t0, $zero, $a0
	
	sw $t0, flea

skip_flea:	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
flea_move:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t1, flea
	lw $t0, 0($t1)
	lw $t5, 4($t1)
	
	beq $t0, 0, skip_flea2
	
	lw $t2, displayAddress 
	li $t3, 0xe6e600
	li $t6, 0x000000
	
	
	sll $t4,$t0, 2
	add $t4, $t2, $t4
	sw $t6, 0($t4)
	
	addi $t0, $t0, 32
	addi $t5, $t5, 1
	
	beq $t5, 32, flea_end
	
	sll $t4,$t0, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)
	j no_end

flea_end:
	addi $t0, $zero, 0
	addi $t5, $zero, 0
	
no_end:
	sw $t0, 0($t1)
	sw $t5, 4($t1)

skip_flea2:	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

delay:
	 #move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $a2, 21000
delay_loop:
	addi $a2, $a2, -1
	bgtz $a2, delay_loop
		
	lw $ra, 0($sp) # pop a word off the stack and move the stack pointer
	addi $sp, $sp, 4
	jr $ra

check_collision:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, centipedLocation
	la $t1, lazer
	la $t2, bugLocation
	la $t6, flea
	
	lw $t3, 36($t0)
	lw $t4, 0($t1)
	lw $t5, 0($t2)
	lw $t7, 0($t6)
	
	beq $t3, $t4, lose
	beq $t3, $t5, lose
	beq $t7, $t4, lose
	beq $t7, $t5, lose
	
	
	lw $ra, 0($sp) # pop a word off the stack and move the stack pointer
	addi $sp, $sp, 4
	jr $ra

win:

	add $t1, $zero, $s3
	
	sw $t1, 0($t0)
	li $t3, 0x00ffff	# $t3 stores the cyan colour code
	
	sll $t4,$t1, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)		# pa$t4int the block with cyan
	
	
	
	li $v0, 4
	la $a0, winMessage
	syscall
	
	la $s6, restart
	addi $s7, $zero, 1
	sw $s7, 0($s6)
	
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	lw $s1, 0($sp)
	addi $sp, $sp, 4
	lw $s2, 0($sp)
	addi $sp, $sp, 4
	lw $s3, 0($sp)
	addi $sp, $sp, 4
	lw $s4, 0($sp)
	addi $sp, $sp, 4
	lw $s5, 0($sp)
	addi $sp, $sp, 4
	lw $s6, 0($sp)
	addi $sp, $sp, 4
	lw $s7, 0($sp)
	addi $sp, $sp, 4
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

lose: 
	li $v0, 4
	la $a0, loseMessage
	syscall
	
	addi $t7, $zero, 0
	sw $t7, 0($t6)
	
	la $s6, restart
	addi $s7, $zero, 1
	sw $s7, 0($s6)
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

res:
	la $t0, restart
	lw $t1, 0($t0)
	beq $t1, 1, check_keys
	j Loop
	
check_keys:
	addi $t1, $zero, 0
	sw $t1, 0($t0)
	
	addi $t2, $zero, 1
key_loop:
	lw $t8, 0xffff0000
	beq $t8, 1, get_keyboard_s	# if key is pressed, jump to get this key
	bne $t2, 0, key_loop
	
	
get_keyboard_s:
	lw $t2, 0xffff0004
	addi $v0, $zero, 0	#default case
	beq $t2, 0x73, resp_s
	j key_loop
	
resp_s:
	lw $t2, displayAddress
	la $t3, centipedLocation
	la $t4, centipedDirection
	addi $t5, $zero, 0
	addi $t6, $zero, 1
	
res_loop:	
	sw $t5, 0($t3)
	sw $t6, 0($t4)
	addi $t3, $t3, 4
	addi $t4, $t4, 4
	addi $t5, $t5, 1
	bne $t5, 10, res_loop
	
	la $t3, health,
	addi $t4, $zero, 3
	sw $t4, 0($t3)
	
	la $t3, flea
	addi $t4, $zero, 0
	sw $t4, 0($t3)
	sw $t4, 4($t3)
	
	
	li $t3, 0x000000
	
make_blackboard:		
	sll $t4,$t6, 2		# $t4 is the bias of the old body location in memory (offset*4)
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	sw $t3, 0($t4)
	addi $t6, $t6, 1
	bne $t6, 1024, make_blackboard
	
	j rest








