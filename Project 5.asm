# Assembly Language Project - "Space Invaders" Fall 2015 CSUEB -

	.data
linesize = 81	
screen:	.space	linesize*25
# note that this screen image will need to use unaligned memory operations for words.

#begin fp constants
fp.ra   = 4
fp.a0   = 8
fp.a1   = 12
fp.a2   = 16
fp.a3   = 20
fp.s0   = -4
fp.s1	= -8
fp.s2	= -12
fp.s3	= -16
fp.s4	= -20
fp.s5	= -24
fp.s6	= -28
fp.s7	= -32
#end fp constants
#begin aliens	
ALIEN_COLS = 11
ALIEN_ROWS = 4	 
	.align 2	
alien1: .ascii "‹€€‹"			# two frames of animation for each alien
	.ascii	 "›±±ﬁ"		# my animation
	.ascii  "‹›ﬁ‹"
af2:	.ascii	 "€‹‹€"
	.ascii	 "ﬂ±±ﬂ"
	.ascii  "!±±!"

alien2: .byte 32,30,30,32    
	.byte 213,2,2,184
	.byte 201,202,202,187
	.byte 32,30,30,32
	.byte 212,2,2,190
	.byte 200,206,206,188
exploded:
	.ascii	"\\≥≥/"
	.ascii  "ƒ˘˘ƒ"
	.ascii	"/≥≥\\"
	
map:	.word	0
	
canon:	.ascii	"‹€‹ "


shield1:	.ascii	"€±±±"
	
	#end aliens
button_left = 37		
button_space = 32		
button_right = 39	
row24	= 1944
spaceAscii	= 32
shi1 = 219 
shi2 = 177
shi3 = 177
shi4 = 177
laser 		.word 0		
isbombing	.word 1
timerformother	.word 25
trackCanon	.word 39	
laserposition	.word 0	
BombLP	.word 0	
laserposscreen	.word 0	
motherposition	.word 1
firstAl	.word	0
aliveAlien	.word	44
multiplier	= 2
aliveMotherShip .word 1
shiledRow = 1782 
elevan	= 1
twenty = 25
five	= 5
seventeen = 17
sevensix = 76
firstchar = 0xDC
secondchar = 0x1E
lastchar = 0xDC
lastadd = 0x100107E8
mes:	.asciiz	"Boom"	

gameoverMessage:	.asciiz	"----GAME--OVER-----\n"
			

#begin DrawAliens Ref: Dr. Roger Doering 
#static variables:
	.extern	animate,1
#global variables:	
	.extern row,1	
	.extern col,1
	.extern dir,1
	.code		
		
		.code
		
DrawAliens:		#void DrawAliens()
	addi	$sp,$sp,-36
	sw	$fp,24($sp)
	addi	$fp,$sp,24
	sw	$ra,fp.ra($fp)
	sw	$s0,fp.s0($fp)
	sw	$s1,fp.s1($fp)
	sw	$s2,fp.s2($fp)
	sw	$s3,fp.s3($fp)
	sw	$s4,fp.s4($fp)
	sw	$s5,fp.s5($fp)
	
	lb	$s1,animate($gp)
	xori	$s1,$s1,af2-alien1
	sb	$s1,animate($gp)	
	lb	$a0,col($gp)
	lb	$a1,row($gp)
	jal	ScreenPointer
	mov	$s0,$v0
	mov	$a1,$v0
	la	$a0,alien1
	add	$a0,$a0,$s1	# add animation offset
	addi	$s2,$0,ALIEN_ROWS
	addi	$s5,$gp,aliens
1:	lh	$s3,leftmost($gp)
	lh	$s4,($s5)
2:	and	$t0,$s3,$s4
	beqz	$t0,3f
	jal	PlaceAlien
3:	addi	$a1,$a1,5		#width of an alien
	lh	$t0,rightmost($gp)
	beq	$t0,$s3,4f
	srl	$s3,$s3,1
	b	2b
4:	addi	$s2,$s2,-1
	add	$s5,$s5,2		# move to next row of aliens
	bne	$s2,2,5f
	addi	$a0,$a0,alien2-alien1
5:	addi	$s0,$s0,linesize*4
	mov	$a1,$s0
	bgtz	$s2,1b
	
	lw	$ra,fp.ra($fp)
	lw	$s0,fp.s0($fp)
	lw	$s1,fp.s1($fp)
	lw	$s2,fp.s2($fp)
	lw	$s3,fp.s3($fp)
	lw	$s4,fp.s4($fp)
	lw	$s5,fp.s5($fp)
	lw	$fp,($fp)
	addi	$sp,$sp,36
	jr	$ra
#end DrawAliens

#begin ScreenPointer Ref: Dr. Roger Doering
ScreenPointer:
	sll	$t0,$a1,6		
	sll	$t1,$a1,4		
	add	$v0,$t0,$t1
	add	$v0,$a1,$v0
	li	$t0,screen	
	add	$v0,$v0,$t0
	add	$v0,$v0,$a0	
	la	$t4,firstAl
	addi	$t8,$v0,161
	sw	$t8,0($t4)
	jr	$ra	
#end ScreenPointer

#begin MoveAliens Ref: Dr. Roger Doering
MoveAliens:
	lb	$t0,col($gp)
	lb	$t1,cols($gp)
	sll	$t2,$t1,2
	add	$t2,$t2,$t1
	lb	$t3,dir($gp)
	add	$t0,$t0,$t3
	add	$t2,$t2,$t0
	bltz	$t0,2f
lz1	=	linesize+1	
	bne	$t2,lz1,3f	
2:	sub	$t0,$t0,$t3	
	lb	$t4,row($gp)
	addi    $t4,$t4,1
	sb	$t4,row($gp)
	sub	$t3,$0,$t3		
	sb	$t3,dir($gp)
	lb	$t5,rows($gp)
	sll	$t5,$t5,2		
	add	$t5,$t5,$t4	
	beq	$t5,26,main	
3:	sb	$t0,col($gp)
	jr	$ra		
#end MoveAliens

#begin ClearScreen Ref: Dr. Roger Doering	
	.code
ClearScreen:
	la	$t0,screen
	addi	$t2,$0,25		
	li	$t3,0x20202020	
	addi	$t4,$0,'\n
1:	
	addi	$t1,$0,4 		
2:	usw	$t3,0($t0)
	usw	$t3,4($t0)
	usw	$t3,8($t0)
	usw	$t3,12($t0)
	usw	$t3,16($t0)
	addi	$t0,$t0,20		
	addi	$t1,$t1,-1 
	bgtz	$t1,2b
	sb	$t4,($t0)		
	addi	$t0,$t0,1
	addi	$t2,$t2,-1
	bgtz	$t2,1b
	sb	$0,-1($t0)
	jr	$ra
#end clear screen	

#begin PlaceAlien Ref: Dr. Roger Doering
PlaceAlien:
# a0: pointer to alien, a1 pointer into screen buffer.
	lw	$t0,($a0)
	lw	$t1,4($a0)
	lw	$t2,8($a0)
	
	usw	$t0,($a1)
	usw	$t1,linesize($a1)
	usw	$t2,linesize*2($a1)
	jr	$ra
#end PlaceAlien

# begin Left Operation on canon 
leftOperation:
	li	$t0,1
	la	$t1,trackCanon
	lw	$t2,0($t1)
	beq	$t0,$t2,return1
	b	l
return1:	jr	$ra
l:	
	li	$t0,0x20202020
	addiu	$t3,$t2,row24
	la	$s2,laserposscreen
	sw	$t3,0($s2)
	la	$a1,screen
	addu	$a1,$a1,$t3
	usw	$t0,0($a1)
	addiu	$t2,$t2,-1
	sw	$t2,0($t1)		
	addiu	$sp,$sp,-4
	sw	$ra,0($sp)
	jal	putcanon
	lw	$ra,0($sp)
	addiu	$sp,$sp,4
	la	$a0,screen	
	syscall	$print_string
	jr	$ra
#end

#begin right operation on canon 
rightOperation:
	li	$t0,77
	la	$t1,trackCanon
	lw	$t2,0($t1)
	beq	$t0,$t2,return2
	b	r
return2:	jr	$ra
r:	
	li	$t0,0x20202020
	addiu	$t3,$t2,row24
	la	$s2,laserposscreen
	sw	$t3,0($s2)
	la	$a1,screen
	addu	$a1,$a1,$t3
	usw	$t0,0($a1)
	addiu	$t2,$t2,1
	sw	$t2,0($t1)		
	addiu	$sp,$sp,-4
	sw	$ra,0($sp)
	jal	putcanon
	lw	$ra,0($sp)
	addiu	$sp,$sp,4
	la	$a0,screen	
	syscall	$print_string
	jr	$ra

#end 

	
#begin uplaser	
upLazer:
	la	$t0,laser
	lw	$t0,0($t0)
	beq	$t0,$zero,nolaserfired	
	b	next
nolaserfired:	jr	$ra
next:	
	la	$t0,laserposition
	lw	$t4,0($t0)
	la	$t1,screen
	addu	$t1,$t1,$t4
	lb	$s1,0($t1)
	beq	$s1,shi1,out
	beq	$s1,shi2,out
	beq	$s1,shi3,out
	beq	$s1,shi4,out
	bne	$s1,spaceAscii,print	
	b	go
print:
	la	$s2,firstAl
	lw	$s2,0($s2)
	sub	$s2,$t1,$s2
	mov	$a0,$s2
	#syscall	$print_int
	
	slti	$t3,$s2,55			# check row alieand hitted by fire for ROW 1
	bnez	$t3,firstRow
	slti	$t3,$s2,379			# check row alieand hitted by fire for ROW 2
	bnez	$t3,secondRow
	slti	$t3,$s2,703			# check row alieand hitted by fire for ROW 3
	bnez	$t3,thirdRow
	slti	$t3,$s2,1027			# check row alieand hitted by fire for ROW 4
	bnez	$t3,forthRow

	
firstRow:			# If Row is first Check For Alient Number
	li	$t3,0
	li	$s7,0		# S7 alien number hitted by fire
check1:
	slti	$s6,$t3,60
	bnez	$s6,tru1
	b	out
tru1:	sgt	$s6,$s2,$t3
	bnez	$s6,rowf1
	mov	$t7,$s7
skip1:	#addi	$s7,$s7,1
	li	$t3,0
	li	$t4,2048
wh1:	slt	$s6,$t3,$s7		# s7 alien hitted by the fire
	bnez	$s6,iterator1
	b	br1
iterator1:	
	div	$t4,$t4,multiplier	# shift the bitfield
	addi	$t3,$t3,1
	b	wh1	
br1:	mov	$a0,$t4
	#syscall	$print_int
	li	$t0,1<<ALIEN_COLS-1	# Set Bitfield for hitted aliens
	sub	$t5,$t0,$t4
	lh	$t0,aliens($gp)
	and	$t5,$t5,$t0
	sh	$t5,aliens($gp)
	
	addi	$t7,$t7,-1			# destroyed Code 
	mul	$t7,$t7,five
	addi	$t7,$t7,1
	la	$s2,firstAl
	lw	$s2,0($s2)
	addi	$s2,$s2,-162
	mov	$a0,$s2
	add	$a0,$a0,$t7
	la	$a1,exploded
	lw	$t7,0($a1)	
	usw	$t7,0($a0)	
	lw	$t7,4($a1)
	addi	$a0,$a0,81
	usw	$t7,0($a0)	
	lw	$t7,8($a1)
	addi	$a0,$a0,81
	usw	$t7,0($a0)
	la	$a0,screen		# destroyed Screen
	syscall	$print_string
	
	la	$t7,aliveAlien
	lw	$s2,0($t7)
	addi	$s2,$s2,-1
	sw	$s2,0($t7)
	
	b	out
rowf1:	addi	$s7,$s7,1
	addi	$t3,$t3,5
	b	check1
	
secondRow:			# If Row is second Check For Alien Number			
	li	$t3,324
	li	$s7,0
check2:
	slti	$s6,$t3,384
	bnez	$s6,tru2
	b	out
tru2:	sgt	$s6,$s2,$t3
	bnez	$s6,rowf2
	mov	$t7,$s7
skip2:	#addi	$s7,$s7,1
	li	$t3,0
	li	$t4,2048
wh2:	slt	$s6,$t3,$s7
	bnez	$s6,iterator2
	b	br2
iterator2:	
	div	$t4,$t4,multiplier
	addi	$t3,$t3,1
	b	wh2
br2:	mov	$a0,$t4
	#syscall	$print_int
	li	$t0,1<<ALIEN_COLS-1	# Set Bitfield for hitted aliens
	sub	$t5,$t0,$t4
	lh	$t0,aliens+2($gp)
	and	$t5,$t5,$t0
	sh	$t5,aliens+2($gp)
	
	addi	$t7,$t7,-1			# destroyed Code 
	mul	$t7,$t7,five
	addi	$t7,$t7,1
	la	$s2,firstAl
	lw	$s2,0($s2)
	addi	$s2,$s2,162
	mov	$a0,$s2
	add	$a0,$a0,$t7
	la	$a1,exploded
	lw	$t7,0($a1)	
	usw	$t7,0($a0)	
	lw	$t7,4($a1)
	addi	$a0,$a0,81
	usw	$t7,0($a0)	
	lw	$t7,8($a1)
	addi	$a0,$a0,81
	usw	$t7,0($a0)
	la	$a0,screen		# destroyed Screen
	syscall	$print_string
	
	la	$t7,aliveAlien
	lw	$s2,0($t7)
	addi	$s2,$s2,-1
	sw	$s2,0($t7)
	
	b	out
rowf2:	addi	$s7,$s7,1
	addi	$t3,$t3,5
	b	check2
	
	
thirdRow:			# If Row is third Check For Alient Number
	li	$t3,648
	li	$s7,0
check3:
	slti	$s6,$t3,708
	bnez	$s6,tru3
	b	out
tru3:	sgt	$s6,$s2,$t3
	bnez	$s6,rowf3
	mov	$t7,$s7
skip3:	#addi	$s7,$s7,1
	li	$t3,0
	li	$t4,2048
wh3:	slt	$s6,$t3,$s7
	bnez	$s6,iterator3
	b	br3
iterator3:
	div	$t4,$t4,multiplier
	addi	$t3,$t3,1
	b	wh3
br3:	mov	$a0,$t4
	#syscall	$print_int
	li	$t0,1<<ALIEN_COLS-1	# Set Bitfield for hitted aliens
	sub	$t5,$t0,$t4
	lh	$t0,aliens+4($gp)
	and	$t5,$t5,$t0
	sh	$t5,aliens+4($gp)
	
	addi	$t7,$t7,-1			# destroyed Code 
	mul	$t7,$t7,five
	addi	$t7,$t7,1
	la	$s2,firstAl
	lw	$s2,0($s2)
	addi	$s2,$s2,486
	mov	$a0,$s2
	add	$a0,$a0,$t7
	la	$a1,exploded
	lw	$t7,0($a1)	
	usw	$t7,0($a0)	
	lw	$t7,4($a1)
	addi	$a0,$a0,81
	usw	$t7,0($a0)	
	lw	$t7,8($a1)
	addi	$a0,$a0,81
	usw	$t7,0($a0)
	la	$a0,screen		# destroyed Screen
	#syscall	$print_string
	
	la	$t7,aliveAlien
	lw	$s2,0($t7)
	addi	$s2,$s2,-1
	sw	$s2,0($t7)
	
	
	b	out
rowf3:	addi	$s7,$s7,1
	addi	$t3,$t3,5
	b	check3
	
	
forthRow:			# If Row is forth Check For Alient Number	
	li	$t3,972
	li	$s7,0
check4:
	slti	$s6,$t3,1032
	bnez	$s6,tru4
	b	out
tru4:	sgt	$s6,$s2,$t3
	bnez	$s6,rowf4
	mov	$t7,$s7
skip4:	#addi	$s7,$s7,1
	li	$t3,0
	li	$t4,2048
wh4:	slt	$s6,$t3,$s7
	bnez	$s6,iterator4
	b	br4
iterator4:
	div	$t4,$t4,multiplier
	addi	$t3,$t3,1
	b	wh4
br4:	mov	$a0,$t4
	#syscall	$print_int
	li	$t0,1<<ALIEN_COLS-1	# Set Bitfield for hitted aliens
	sub	$t5,$t0,$t4
	lh	$t0,aliens+6($gp)
	and	$t5,$t5,$t0
	sh	$t5,aliens+6($gp)
	
	addi	$t7,$t7,-1			# destroyed Code 
	mul	$t7,$t7,five
	addi	$t7,$t7,1
	la	$s2,firstAl
	lw	$s2,0($s2)
	addi	$s2,$s2,810
	mov	$a0,$s2
	add	$a0,$a0,$t7
	la	$a1,exploded
	lw	$t7,0($a1)	
	usw	$t7,0($a0)	
	lw	$t7,4($a1)
	addi	$a0,$a0,81
	usw	$t7,0($a0)	
	lw	$t7,8($a1)
	addi	$a0,$a0,81
	usw	$t7,0($a0)
	la	$a0,screen		# destroyed Screen
	syscall	$print_string
	
	la	$t7,aliveAlien
	lw	$s2,0($t7)
	addi	$s2,$s2,-1
	sw	$s2,0($t7)
	
	
	b	out
rowf4:	addi	$s7,$s7,1
	addi	$t3,$t3,5
	b	check4
	
out:	b	nolazer		# if there is not fire anymore 	
go:	addiu	$t2,$zero,186	
	sb	$t2,0($t1)	
  	la	$a0,screen	
	syscall	$print_string
	slti	$t2,$t4,81
	bne	$t2,$zero,nolazer 
	addiu	$t4,$t4,-81	
	sw	$t4,0($t0)	
	jr	$ra
#end 
	

	
	
#begin nolaser	
nolazer:
	la	$t0,laser
	sw	$zero,0($t0)	
	j	nolaserfired
#end nolaser	
	
#begin makelaserup	
makelaserup:
	la	$t0,laser
	lw	$t0,0($t0)
	beq	$t0,$zero,nolaseryet	
	la	$t0,laserposition
	lw	$t0,0($t0)
	la	$t1,screen
	addu	$t1,$t1,$t0
	addiu	$t2,$zero,0x20
	sb	$t2,81($t1)	
	bltz	$t0,nolazer
nolaseryet:	jr	$ra
#end

#begin spaceoperation on spacebar clicked
spaceOperation:
	la	$t0,laser
	lw	$t1,0($t0)
	bne	$t1,$zero,yeslaser	
	addiu	$t1,$zero,1
	sw	$t1,0($t0)	
	la	$t0,laserposition
	la	$s2,laserposscreen
	lw	$s2,0($s2)
	addiu	$s2,$s2,-81
	sw	$s2,0($t0)	
yeslaser:	jr	$ra
#end 

#begin Putcanon on the screen
putcanon:
	li	$t0,0xDC1EDC20
	la	$a1,screen
	la	$t1,trackCanon
	lw	$t2,0($t1)
	addiu	$t1,$t2,row24
	addu	$a1,$a1,$t1
	addi	$a1,$a1,-1
	usw	$t0,0($a1)
	jr	$ra
#end

#begin
mothership:
	la	$t1,timerformother
	lb	$t3,0($t1)
	addi	$t3,$t3,-1
	sb	$t3,0($t1)
	beqz	$t3,mothershiprelease
	b	out9
mothershiprelease:
	la	$t2,aliveMotherShip
	sb	$0,0($t2)
	li	$t7,twenty
	sb	$t7,0($t1)
out9:	jr	$ra
#end

#begin
movemother:
	la	$t2,aliveMotherShip
	lb	$t3,0($t2)
	beqz	$t3,move1
	b	nomother
move1:	la	$s1,motherposition
	lb	$t5,0($s1)
	li	$t6,sevensix
	blt	$t5,$t6,goahead
	b	nomother1
goahead:
	la	$a0,screen
	add	$a0,$a0,$t5
	addiu	$t5,$t5,1
	sb	$t5,0($s1)
	li	$t7,0x20202020	
	usw	$t7,0($a0)
	addi	$a0,$a0,1
	li	$t7,0xDFDCDF20
	usw	$t7,0($a0)
	b	nomother
nomother1:	
	li	$t7,1
	sb	$t7,0($t2)		
nomother:	jr	$ra	
#end

#begin Bombing
Bombing:
	la	$t3,isbombing
	la	$t4,BombLP
	lb	$s3,0($t3)
	beqz	$s3,out1
	la	$s2,laserposscreen
	lw	$s2,0($s2)
	addi	$s2,$s2,1
	la	$a0,screen
	add	$a0,$a0,$s2
	li	$t2,22
doW:	addi	$a0,$a0,-81	
	lb	$t1,0($a0)
	addi	$t2,$t2,-1
	beqz	$t2,out4
	bne	$t1,spaceAscii,findAlien	
	b	doW	
findAlien:	
again:	addi	$a0,$a0,1
	lb	$t1,0($a0)
	beq	$t1,spaceAscii,lastChar
	b	again
lastChar:
	addi	$a0,$a0,-2
	li	$t1,0x02
	addi	$a0,$a0,81
	usw	$t1,0($a0)
	sw	$a0,0($t4)
out1:	sb	$0,0($t3)
out4:	jr	$ra
#end 

#begin DownBomb

downbomb:
	la	$t3,isbombing	
	la	$t4,BombLP
	lb	$t5,0($t3)
	beqz	$t5,movebomb
	b	out3
movebomb:
	lw	$a1,0($t4)
	li	$t1,0x20
	sb	$t1,0($a1)
	li	$s3,lastadd
	addi	$a1,$a1,81
	bgt	$a1,$s3,out2
	lb	$t2,0($a1)
	li	$t1,0xdc	#DC1EDC
	beq	$t1,$t2,gameover
	li	$t1,0x1e
	beq	$t1,$t2,gameover
	li	$t1,0xdc
	beq	$t1,$t2,gameover
	lb	$t2,0($a1)
	mov	$a0,$t2
	syscall	$print_char
	li	$t1,0x99
	sb	$t1,0($a1)
	lb	$t2,0($a1)	
	sw	$a1,0($t4)
	#a	$a0,screen
	#syscall	$print_string
	b	out3
out2:	li	$s3,1
	sb	$s3,0($t3)
out3:	jr	$ra	

gameover:	jal	ClearScreen
		la	$a0,gameoverMessage
		syscall	$print_string
		syscall	$exit
#end


#begin putshields
putshields:	
	la	$a0,screen
	addi	$a0,$a0,shiledRow
	addi	$a0,$a0,15
	la	$a1,shield1
	lw	$t1,0($a1)
	usw	$t1,0($a0)
	addi	$a0,$a0,19
	usw	$t1,0($a0)
	addi	$a0,$a0,19
	usw	$t1,0($a0)
	la	$a0,screen
	syscall	$print_string
	jr	$ra
#end

#begin main 	
	
	.globl main
main:	
	li	$t0,1<<ALIEN_COLS-1	#full row of aliens
	#sub	$t0,$t0,32
	#or	$t0,$t0,$t1
	li	$t1,0
	sh	$t0,aliens($gp)
	sh	$t0,aliens+2($gp)
	sh	$t0,aliens+4($gp)
	sh 	$t0,aliens+6($gp)
	addi	$t0,$0,1
	sb	$t0,dir($gp)
	sb	$0,row($gp)
	
	la	$t1,trackCanon
	lw	$t2,0($t1)
	addiu	$t3,$t2,row24
	la	$s2,laserposscreen
	sw	$t3,0($s2)
	
	
	
	jal	FindBounds
eventloop:
	la	$a0,timer.t1
	addi	$a1,$0,4
	la	$t7,aliveAlien
	lw	$s2,0($t7)
minsec	=	9
	blt	$s2,minsec,yes
	mul	$s2,$s2,seventeen
	mov	$a2,$s2
	b	ju
yes:	
	li	$s2,minsec
	mul	$s2,$s2,seventeen
	mov	$a2,$s2
ju:	syscall	$IO_write

	la	$a0,timer.t2
	addiu	$a1,$zero,4
	addu	$a2,$zero,17
	syscall	$IO_write
	
clear:	jal	ClearScreen
	jal	MoveAliens
	jal	DrawAliens
	jal	putshields
	jal	putcanon
	jal	Bombing
	jal	downbomb
		
	jal	mothership
	jal	movemother
	
	mov	$a0,$0
	mov	$a1,$0
	syscall	$xy
	la	$a0,screen
	syscall	$print_string
	b	keyFlag
			
down:		andi	$t1,$t0,2		
		neg	$t1,$t1			
		bltzal	$t1,checkInput
		b	nothing
checkInput:	
		la	$a0,keyboard.keydown	
		addi	$a1,$0,2		
		syscall	$IO_read
		mov	$t8,$v0
		beq	$t8,button_left,leftOperation
		beq	$t8,button_right,rightOperation
		beq	$t8,button_space,spaceOperation
		
nothing:		
noinput:	la	$a0,timer.flags
		addi	$a1,$zero,1
		syscall	$IO_read
		andi	$t0,$v0,4	
		beqz	$t0,keyFlag			
		jal	putcanon
		jal	upLazer
		jal	makelaserup		
		jal	putcanon
		la	$a0,timer.flags
		addi	$a1,$zero,1
		syscall	$IO_read
		andi	$t0,$v0,2
		beqz	$t0,keyFlag			
		la	$a0,timer.flags
		addi	$a1,$zero,1	
		addiu	$a0,$a0,4
		syscall	$IO_read
		j	eventloop	

keyFlag:	la	$a0,keyboard.flagsl	
		addiu	$a1,$0,1		
		syscall $IO_read		
		blez	$v0,noinput			
		move	$t0,$v0
		b	down
#end main	
	
#begin bounds Ref: Dr. Roger Doering

	.data
	.extern	aliens,8		# 4 bitsets. each row of aliens
	.extern leftmost,2		# bitmask for position of leftmost alien
	.extern rightmost,2		# bitmask for position of rightmost alien
	.extern	cols,1			# columns of aliens remaining
	.extern	rows,1			# rows of aliens remaining
	.code
FindBounds:				#void FindBounds()
	lh	$t0,aliens($gp) 	#{
	lh	$t1,aliens+2($gp)	#    short merged;
	lh	$t2,aliens+4($gp)
	or	$t0,$t0,$t1		#    merged = aliens[0]|aliens[1]|aliens[2]|aliens[3];
	lh	$t1,aliens+6($gp)
	or	$t0,$t0,$t2
	or	$t0,$t0,$t1
	bnez	$t0,1f			#    if (!merged){
	sb	$0,cols($gp)		#	cols = rows = 0;
	sb	$0,rows($gp)		#	return;
	jr	$ra			#    }
ACM1	= ALIEN_COLS-1	
1:	addi	$t1,$0,1<<ACM1		#	leftmost = 1<<(ALIEN_COLS-1);
	b	3f			#	while (!(merged & leftmost)) 
2:	srl	$t1,$t1,1		#	    leftmost >>= 1;
3:	and	$t2,$t1,$t0
	beqz	$t2,2b
	sh	$t1,leftmost($gp)	
	addi	$t3,$0,1		#	rightmost = 1;
	b	3f			#	while (!(merged & rightmost))
2:	sll	$t3,$t3,1		#	    rightmost <<= 1;	
3:	and	$t2,$t3,$t0		
	beqz	$t2,2b 			
	sh 	$t3,rightmost($gp)
	addi	$t0,$0,1			#	cols = 1;
					#	unsigned short temp = rightmost;
	b	3f			#	while (!(temp & leftmost)) 
2:	sll	$t3,$t3,1		#	    {temp <<= 1; cols++;}
	addi	$t0,$t0,1
3:	and	$t2,$t3,$t1		
	beqz	$t2,2b
	sb	$t0,cols($gp)		
	addi	$t0,$0,ALIEN_ROWS		#	rows = ALIEN_ROWS ;
	addi	$t1,$gp,ALIEN_ROWS-1<<1+aliens	# unsigned short ptr = & aliens[ALIEN_ROWS-1]
	b	3f			#	while (rows >= 0 && !*aliens--]) rows--;
2:	addi	$t0,$t0,-1		
3:	bltz	$t0,4f
	lh	$t2,($t1)
	addi	$t1,$t1,-2
	beqz	$t2,2b
4:	sb	$t0,rows($gp)		#
	jr	$ra			#}
#end bounds	

				
#begin IO hardware------------------------------Ref: Dr. Roger Doering----------------------------------------------
keyboard:	.struct 0xa0000000	#start from hardware base address
flagsl:		.byte 0
mask:		.byte 0
		.half 0
keypress: 	.byte 0,0,0
presscon: 	.byte 0
keydown:	.half 0
shiftdown:	.byte 0
downcon:	.byte 0
keyup:		.half 0
upshift:	.byte 0
upcon:		.byte 0
#----------------------------------------------------------------------------
		.data
timer:		.struct 0xA0000050	
flags:		.byte 0
mask:		.byte 0
		.half 0
t1:		.word 0
t2:		.word 0
t3:		.word 0
t4:		.word 0
t5:		.word 0
t6:		.word 0
t7:		.word 0

	.code
#end IO hardware