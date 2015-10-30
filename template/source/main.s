.section    .init
.globl     gogo

gogo:
        b       main
    
.section .text

main:
        mov     sp, #0x8000		
	

	bl	EnableJTAG		// Turn on that debugger
	mov	r0, #42			// Move 42 to r0. Does frame buffer stufffffs

        
	bl	InitFrameBuffer		// Init the framebuffer
	cmp	r0, #0			// Check for error
	beq	haltLoop$       	// branch to the halt loop if there was an error initializing the framebuffer
	bl 	initializeController



initialize:
	ldr	r1, =gameState		// Load the game state
	mov	r2, #1			// Move 1 to initialize game state
	str	r2, [r1]		// Change game state
	mov	r4, #0			// Initialize reset code
	b	reset

gameLoop:
	ldr	r1, =gameState		// Load address for game state
	ldr	r2, [r1]		// Load it
	cmp	r2, #3			// Check if loss
	beq	loseScreen		// Branch to loss
	cmp	r2, #2			// Check if win
	beq	winScreen		// Branch to win
	bl	drawBorder		// Draw the border again
	bl	waitInput		// Wait on SNES input
	tst 	r12, #0x40		// Check left
	bleq 	moveLeft		// Do left if pressed
	beq 	reloop			// Don't make more than one move - skip
	tst	r12, #0x80		// Check right
	bleq 	moveRight		// Do right if pressed
	beq 	reloop			// Don't make more than one move - skip
	tst 	r12, #0x10		// Check up
	bleq 	moveUp			// Do up if pressed
	beq 	reloop			// Don't make more than one move - skip
	tst 	r12, #0x20		// Check down
	bleq 	moveDown		// Do down if pressed
	beq 	reloop			// Don't make more than one move - skip
	tst 	r12, #0x100		// Check A
	bleq 	shootBullet		// Do shoot if pressed
	beq 	reloop			// Don't make more than one move - skip
	tst 	r12, #0x8		// Check Start
	bleq 	pauseScreen		// Do pause
reloop:	
	tst 	r12, #0xC00		// Check both triggers down
	beq 	cheat			// Pull some matrix stuff, jump to cheat
	ldr	r1, =QueenA	
	bl	moveUnit		// Move Queen A
	ldr	r1, =QueenA
	bl 	EShootBullet		// Shoot it's bullet (conditions inside)
	ldr	r1, =QueenA
	add	r1, #24			// Bullet offset
	bl 	moveEBullet		// Move it's bullet (conditions inside)
	ldr	r1, =QueenB
	bl	moveUnit		// Move Queen B
	ldr	r1, =QueenB
	bl 	EShootBullet		// Shoot it's bullet (conditions inside)
	ldr	r1, =QueenB
	add	r1, #24			// Bullet offset
	bl 	moveEBullet		// Move it's bullet (conditions inside)
	ldr	r1, =Knight
	bl	moveUnit		// Move Knight
	ldr	r1, =Knight
	bl 	EShootBullet		// Shoot it's bullet (conditions inside)
	ldr	r1, =Knight
	add	r1, #24			// Bullet offset
	bl 	moveEBullet		// Move it's bullet (conditions inside)
	ldr	r1, =Pawn
	bl	moveUnit		// Move Pawn
	ldr	r1, =Pawn
	bl	moveUnit		// Move Pawn again beacuse it's a beast
	ldr	r1, =Pawn
	bl 	EShootBullet		// Shoot it's bullet (conditions inside)
	ldr	r1, =Pawn
	add	r1, #24			// Bullet offset
	bl 	moveEBullet		// Move it's bullet (conditions inside)
cheat:	bl 	moveBullet		// move player bullet
	ldr	r1, =QueenA
	bl	UnitVsWorld		// Check if Queen A bullet hit something
	ldr	r1, =QueenB
	bl	UnitVsWorld		// Check if Queen b bullet hit something
	ldr	r1, =Knight
	bl	UnitVsWorld		// Check if knight bullet hit something
	ldr	r1, =Pawn
	bl	UnitVsWorld		// Check if pawn bullet hit something
	bl	PlayerVsWorld		// Check if player bullet hit something
	bl	clearscore		// Cover score w/ black box
	bl	drawscore		// Draw new score
	bl 	checkWin		// Check if user won
	b 	gameLoop		// take it backkkk yoooo

pulse:
	push 	{r4-r10, lr}
	mov	r3, #6			// Wait 6 microseconds
	bl	waitFunction
	mov	r1, #0			// Send 0 o clock
	bl	writeClk
	mov	r3, #6			// Wait 6 microseconds
	bl	waitFunction
	bl 	readSNES		// Read that button
	lsl 	r1, r11			// Move to the left to get position of bit
	orr 	r12, r1			// Put read bit into r12
	mov 	r1, #1			// Write 1 to clock to flip
	bl 	writeClk
	add 	r11, #1			// i++
	cmp	r11, #16		// i<16; pulse
	blt 	pulse
	pop 	{r4-r10, pc}
	
winScreen:
	bl	drawMessageBox		// Draws box in center
	mov 	r1, #300		// Offset for text
	add 	r1, #80			// Increase offset
	mov 	r5, #500		// Offset for text
	bl	printWin		// Prints the win text
	mov	r3, #4096		// Time to wait
	lsl	r3, #8			// Increases time to wait
	bl	waitFunction		// Waits
winner:	bl	waitInput		// Gets input from SNES
	ldr 	r10, =resetInt		// Address for no buttons pushed down
	ldr 	r4, [r10]		// Gets the integer for no buttons pressed
	cmp 	r12, r4			// Checks if a button is pressed
	bne	initialize		// Branches if button is pressed
	b 	winner			// Loops to wait for a button to be pressed

	
loseScreen:
	bl	drawMessageBox		// Draws box in center
	mov 	r1, #300		// Offset for text
	add 	r1, #80			// Increase offset
	mov 	r5, #500		// Offset for text
	bl	printLose		// Prints the lose text
	mov	r3, #4096		// Time to wait
	lsl	r3, #8			// Increase time to wait
	bl	waitFunction		// Waits
loser:	bl	waitInput		// Gets input from SNES
	ldr 	r10, =resetInt		// Address for no buttons pushed down
	ldr 	r4, [r10]		// Gets the integer for no buttons pressed
	cmp 	r12, r4			// Checks if a button is pressed
	bne	initialize		// Branches if button is pressed
	b 	loser			// Loops to wait for a button to be pressed

pauseScreen:
	push 	{lr}
	bl 	menu			// Branches to menu options
	mov 	r4, #10			// Number to check if game was restarted or resumed
	bl 	reset			// Resumes game
	pop 	{pc}

menu:
	push 	{lr}
	mov 	r7, #0			// Position of arrow
menuL:
	bl	drawMessageBox		// Draws box in center
	tst 	r12, #0x100		// Checks if (A) is pressed
	beq	performTask		// Performs task if (A) is pressed
	mov 	r1, #300		// Offset for text
	add 	r1, #60			// Adds to offset
	mov 	r5, #500		// Offset for text
	bl	drawResume		// Draws text
	mov 	r1, #300		// Offset for text
	add 	r1, #80			// Adds to offset
	mov 	r5, #500		// Offset for text
	bl	drawRestart		// Draws text
	mov 	r1, #400		// Offset for text
	mov 	r5, #500		// Offset for text
	bl	drawQuit		// Draws text
	mov 	r1, #300		// Offset for text
	add 	r1, #60 		// Adds to offset
	mov 	r6, #20			// Offset of arrow
	mul 	r3, r7, r6		// Also offset of arrow
	add 	r1, r3			// One more arrow offset
	mov 	r5, #400		// Offset for text
	add 	r5, #75			// Adds to offset
	bl	drawArrow		// Draws text
inputL:	bl 	waitInput		// Gets input from SNES
	tst 	r12, #0x10		// Checks if up is pressed
	addeq 	r7, #-1			// Moves arrow up if up is pressed
	tst 	r12, #0x20		// Checks if down is pressed
	addeq 	r7, #1			// Moves arrow down if down is pressed
	ldr 	r10, =resetInt		// Gets the address of integer
	ldr 	r4, [r10]		// Gets integer for if nothing is pressed
	cmp 	r12, r4			// Checks to see if nothing is pressed
	beq 	inputL			// Branches if nothing is pressed
	cmp 	r7, #0			// Checks if arrow is in bounds
	movlt 	r7, #0			// Keeps arrow in bounds
	cmp 	r7, #2			// Checks if arrow is in bounds
	movgt 	r7, #2			// Keeps arrow in bounds
	mov	r3, #4096		// Time to wait
	lsl	r3, #6			// Increases time to wait
	bl	waitFunction		// Waits
	b 	menuL			// Stays in menu


performTask:
	bl	clsmsgbx		// Clears box in center
	cmp	r7, #0			// Checks arrow location
	moveq 	r4, #10			// Number to resume
	bleq 	reset			// Jump to reset when resuming
	beq	gameLoop		// Goes back to gameloop
	cmp	r7, #1			// Checks arrow location
	beq	initialize		// Restarts the game
	b	endGame			// Ends the game

endGame:
	mov 	r1, #0			// x = 0
	mov	r2, #0			// y = 0
	ldr	r3, =0x000000		// BLACK
	mov 	r5, #1024		// max width
	mov 	r6, #768		// max height
	mov 	r7, #0			// i for i++
	mov 	r8, #0			// j for j++
	bl	drawObject		// Makes screen black
	b	haltLoop$		// Infinite loop
	

waitInput:
	push	{r4-r10, lr}
	mov	r1, #1			// Number to write to clock/latch
	bl	writeClk		// Writes to the clock
	bl	writeLat		// Writes to the latch
	mov	r3, #12			// Time to wait
	bl	waitFunction		// Waits
	mov	r1, #0			// Number to write to latch
	bl	writeLat		// Writes to the latch
	mov	r12, #0  		// controller state init		
	mov	r11, #0  		// pulse count init
	bl 	pulse			// Pulse loop for input
	pop	{r4-r10, pc}

reset:
	mov 	r1, #0			// x = 0
	mov	r2, #0			// y = 0
	ldr	r3, =0x000000		// BLACK
	mov 	r5, #1024		// max width
	mov 	r6, #768		// max height
	mov 	r7, #0			// i for i++
	mov 	r8, #0			// j for j++
	bl	drawObject		// Wipe the screen
	bl 	drawBorder		// Draw the blue border
	bl	namesAndTitle		// lukas, sumeet, jeremy + title to screen
	cmp	r4, #10			// Check if reset means literally reset or just redraw
	beq 	drawIt			// It meant redraw
	bl	resetPlayer		// It meant really reset
	bl	resetEnemy		// It meant really reset
	bl	resetWalls		// It meant really reset
drawIt:	ldr	r1, =Player		// Draw the player
	mov	r2, #1
	bl 	drawPlayer
	ldr	r1, =QueenA		// Draw the Upper queen	
	mov	r2, #1
	bl	drawObj
	ldr	r1, =QueenB		// Draw the Lower Queen	
	mov	r2, #1
	bl	drawObj
	ldr	r1, =Pawn		// Draw the Pawn	
	mov	r2, #1
	bl	drawObj
	ldr	r1, =Knight		// Draw the Knight	
	mov	r2, #1
	bl	drawObj
	ldr	r1, =Wall1		// Draw the Wall	
	mov	r2, #1
	bl	drawBarrier
	ldr	r1, =Wall2		// Draw the Wall2	
	mov	r2, #1
	bl	drawBarrier
	ldr	r1, =Wall3		// Draw the Wall3	
	mov	r2, #1
	bl	drawBarrier
	ldr	r1, =Wall4		// Draw the Wall4	
	mov	r2, #1
	bl	drawBarrier
	ldr	r1, =Wall5		// Draw the Wall5	
	mov	r2, #1
	bl	drawBarrier
	ldr	r1, =Wall6		// Draw the Wall6	
	mov	r2, #1
	bl	drawBarrier
	b	gameLoop		// Start looping again
	
	
	
haltLoop$:
	b	haltLoop$

.section .data
.align 4

resetInt: .int 65535		//0xFFFF would not load so we had to use this for all buttons depressed
.global gameState
gameState:      .int    1       // 1 in game loop, 2 in win state, 3 in lose state
