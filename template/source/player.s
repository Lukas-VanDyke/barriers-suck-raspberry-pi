.section .text

.global drawPlayer
drawPlayer:
	push	{r4-r10, lr}
	mov	r4, r1			// r1 should have address of Object to draw
	cmp	r2, #1			// r2 contains clear (0) or draw (1) or draw red (2)
	ldrlt	r3, =0x000000		// clear
	ldreq	r3, =0xCCCCCC		// draw
	ldrgt 	r3, =0xF800		// draw red
	ldr	r1, [r4, #8]		// load x
	ldr	r2, [r4, #12]		// load y
	ldr	r5, [r4]		// load width
	ldr	r6, [r4, #4]		// load height
	mov	r7, #0			// initialize counter
	mov	r8, #0			// initialize counter
	bl	drawObject
	pop	{r4-r10, pc}


.global moveLeft
moveLeft:
	push	{r4-r10, lr}
	ldr 	r1, =Player		// load player structure
	mov 	r2, #0			// number to clear
	bl 	drawPlayer		// clears the player
	ldr	r10, =Player		// loads the player structure
	ldr	r4, [r10, #8]		// load x value
	add	r4, #-1			// move player left 1 pixel
	cmp 	r4, #1			// make sure player is in bounds
	beq 	skip1			// skip if player out of bounds
	str	r4, [r10, #8]		// store new x value
skip1:
	ldr 	r1, =Player		// load player structure
	mov 	r2, #1			// number to draw player
	bl	drawPlayer		// draws the player
	pop	{r4-r10, pc}

.global moveRight
moveRight:
	push	{r4-r10, lr}
	ldr 	r1, =Player		// load player structure
	mov 	r2, #0			// number to clear
	bl 	drawPlayer		// clears the player
	ldr	r10, =Player		// loads the player structure
	ldr	r4, [r10, #8]		// load x value
	add	r4, #1			// move player right 1 pixel
	mov 	r5, #900
	add 	r5, #73
	cmp 	r4, r5			// make sure player is in bounds
	beq 	skip2			// skip if player out of bounds
	str	r4, [r10, #8]		// store new x value
skip2:
	ldr 	r1, =Player		// load player structure
	mov 	r2, #1			// number to draw player
	bl	drawPlayer		// draws the player
	pop	{r4-r10, pc}

.global moveUp
moveUp:
	push	{r4-r10, lr}
	ldr 	r1, =Player		// load player structure
	mov 	r2, #0			// number to clear
	bl 	drawPlayer		// clears the player
	ldr	r10, =Player		// loads the player structure
	ldr	r4, [r10, #12]		// load y value
	add	r4, #-1			// move player up 1 pixel
	cmp 	r4, #400		// make sure player is in bounds
	beq 	skip3			// skip if player out of bounds
	str	r4, [r10, #12]		// store new y value
skip3:
	ldr 	r1, =Player		// load player structure
	mov 	r2, #1			// number to draw player
	bl	drawPlayer		// draws the player
	pop	{r4-r10, pc}

.global moveDown
moveDown:
	push	{r4-r10, lr}
	ldr 	r1, =Player		// load player structure
	mov 	r2, #0			// number to clear
	bl 	drawPlayer		// clears the player
	ldr	r10, =Player		// loads the player structure
	ldr	r4, [r10, #12]		// load y value
	add	r4, #1			// move player down 1 pixel
	mov 	r5, #640		// value to make sure player is in bounds	
	add 	r5, #75			// value to make sure player is in bounds
	cmp 	r4, r5			// make sure player is in bounds
	beq 	skip4			// skip if player out of bounds
	str	r4, [r10, #12]		// store new y value
skip4:
	ldr 	r1, =Player		// load player structure
	mov 	r2, #1			// number to draw player
	bl	drawPlayer		// draws the player
	pop	{r4-r10, pc}


.global moveBullet
moveBullet:
	push	{r4-r10, lr}
	ldr 	r10, =Player		// loads the player structure
	ldr 	r8, [r10, #16]		// loads the bullet width
	cmp 	r8, #0			// if bullet width =0, theres no bullet to move
	beq 	else			// skip if no bullet
	ldr 	r1, =Player		// load the player structure
	add 	r1, #16			// get address of bullet
	mov 	r2, #0			// number to clear
	bl 	drawPlayer		// clear the bullet
	ldr	r4, [r10, #28]		// get the bullet y pos
	add	r4, #-2			// move bullet up 2
	cmp 	r4, #0			// make sure bullet is in bounds
	ble 	deleteBullet		// delete bullet if out of bounds
	str	r4, [r10, #28]		// store new bullet position
	ldr 	r1, =Player		// loads the player structure
	add 	r1, #16			// loads the bullet width
	mov 	r2, #1			// number to draw bullet
	bl	drawPlayer		// draws the bullet
	b 	else			// skips delete bullet
deleteBullet:
	ldr 	r1, =Player		// load the player structure
	add 	r1, #16			// get address of bullet
	mov 	r2, #0			// number to clear
	bl 	drawPlayer		// clear the bullet
	mov 	r5, #0			// new bullet width and height
	str 	r5, [r10, #16]		// stores the new bullet width
	str 	r5, [r10, #20]		// stores new bullet height
	mov 	r6, #1000		// new bullet x and y pos
	str 	r6, [r10, #24]		// stores the new bullet x pos
	str 	r6, [r10, #28]		// stores the new bullet y pos
	mov 	r1, #1			// if the bullet hit something
else:
	pop	{r4-r10, pc}


.global shootBullet
shootBullet:
	push	{r4-r10, lr}
	ldr 	r10, =Player		// loads the player structure
	ldr 	r4, [r10, #16]		// loads the bullet width
	cmp 	r4, #0			// if bullet width is greater than 0, there is a bullet
	bne 	dontShoot		// dont shoot another bullet if there is already a bullet
	mov 	r4, #5			// new bullet width and height
	str 	r4, [r10, #16]		// stores the new bullet width
	str 	r4, [r10, #20]		// stores the new bullet height
	ldr 	r5, [r10, #8]		// loads the player x pos
	add 	r5, #22			// adds 22 to player x pos for bullet starting pos
	ldr	r6, [r10, #12]		// loads the player y pos 
	add 	r6, #-5			// subtracts 5 from player y pos for bullet starting pos
	str 	r5, [r10, #24]		// stores bullet starting x
	str 	r6, [r10, #28]		// stores bulelt starting y
	add 	r1, r10, #16  		// loads bullet structure
	mov 	r2, #1 			// number to draw
	bl 	drawPlayer 		// draws the bullet
dontShoot:
	pop	{r4-r10, pc}

.global PlayerVsWorld
PlayerVsWorld:
	push	{r4-r10, lr}
	ldr	r10, =Player		// loads player structure
	ldr	r4, [r10, #24]		// gets bullet x pos
	ldr	r5, [r10, #28]		// gets bullet y pos
	ldr	r1, =Wall1		// Load address of Wall1 for checking
	bl	BarrierCollision	// Check for collision at Wall1
	cmp	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq	hit			// Delete the bullet if a hit is found
	ldr	r1, =Wall2		// Load address of Wall2 for checking
	bl	BarrierCollision	// Check for collision at Wall1
	cmp	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq	hit			// Delete the bullet if a hit is found
	ldr	r1, =Wall3		// Load address of Wall3 for checking
	bl	BarrierCollision	// Check for collision at Wall1
	cmp	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq	hit			// Delete the bullet if a hit is found
	ldr	r1, =Wall4		// Load address of Wall4 for checking
	bl	BarrierCollision	// Check for collision at Wall1
	cmp	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq	hit			// Delete the bullet if a hit is found
	ldr	r1, =Wall5		// Load address of Wall5 for checking
	bl	BarrierCollision	// Check for collision at Wall1
	cmp	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq	hit			// Delete the bullet if a hit is found
	ldr	r1, =Wall6		// Load address of Wall6 for checking
	bl	BarrierCollision	// Check for collision at Wall1
	cmp	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq	hit			// Delete the bullet if a hit is found
	ldr 	r1, =QueenA 		// Load address of queen A
	bl 	UnitHit			// Check for collision with Queen A
	cmp 	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq 	hit			// Delete the bullet if a hit is found
	ldr 	r1, =QueenB		// Load address of queen B
	bl 	UnitHit			// Check for collision with Queen B
	cmp 	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq 	hit			// Delete the bullet if a hit is found
	ldr 	r1, =Knight 		// Load address of Knight
	bl 	UnitHit			// Check for collision with Knight
	cmp 	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq 	hit			// Delete the bullet if a hit is found
	ldr 	r1, =Pawn 		// Load address of Pawn
	bl 	UnitHit			// Check for collision with Pawn
	cmp 	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq 	hit			// Delete the bullet if a hit is found
	b 	miss
hit:	b	deleteBullet		// Deletes the bullet
miss:	pop	{r4-r10, pc}


.global changeHealth
changeHealth:
	push 	{r4-r10, lr}
	ldr 	r10, =Player		// Loads player structure
	ldr	r4, [r10, #32]		// Loads the players health
	add	r4, r1			// Add the health increase or decrease
	str	r4, [r10, #32]		// Store the new health
	cmp 	r4, #0
	ldrle	r10, =gameState		// Loads the game state
	movle	r8, #3			// Change to lose state
	strle	r8, [r10]		// Stores new game state
	pop 	{r4-r10, pc}

.global PlayerHit;
PlayerHit:
	push	{r6-r10, lr}
	ldr 	r10, =Player 		// Loads player structure
	ldr 	r6, [r10, #8]		// Loads x pos
	ldr	r7, [r10, #12]		// Loads y pos
	add	r6, #-1			// Alters x pos
	cmp	r4, r6			// Compares enemy bullet x pos to x pos
	blo	no			// Not hit
	ldr	r8, [r10]		// Loads player width
	add	r6, r8			// Adds width to x pos
	cmp	r4, r6			// Compares enemy bullet x pos to new x pos
	bhi	no			// Not hit
	cmp	r5, r7			// Compares enemy bullet y pos to y pos
	blo	no			// Not hit
	ldr	r8, [r10, #4]		// Loads player height
	add	r7, r8			// Adds height to y pos
	cmp	r5, r7			// Compares enemy bullet y pos to new y pos
	bhi	no			// Not hit
	ldr 	r1, =Player 		// Loads player structure
	mov 	r2, #2			// Number to draw player red
	bl	drawPlayer		// Draws player red
	mov	r3, #4096		// Wait time
	lsl 	r3, #6			// Extends the wait time
	bl	waitFunction		// Waits
	ldr 	r1, =Player 		// Loads player structure
	mov 	r2, #1 			// Number to draw player
	bl	drawPlayer		// Draws the player
	b	ifhurt			// If hit
no:	mov	r1, #0			// Confirms not hit
	pop	{r6-r10, pc}
ifhurt:
	mov	r1, #-10		// Value to alter health
	bl	changeHealth 		// Changes player health
	mov 	r1, #1			// Confirm the hit	
	pop	{r6-r10, pc}

.global resetPlayer
resetPlayer:
	push	{r4-r10, lr}
	ldr	r4, =EndOfReset		// Load labels for reset loop
	ldr	r5, =Player		// Loads player structure
	ldr	r6, =Reset		// Loads reset structure
rLoop:
	ldr	r7, [r6], #4		// Load r6 into r7, increment by 4 after
	str	r7, [r5], #4		// Store r7 into r5, increment by 4 after	
	cmp	r6, r4
	bne	rLoop			// Break when address at r5 = EndOfReset
	pop	{r4-r10, pc}

.section .data
.align 4

.global Player
Player:	.int	50			// Player X Resolution (width)
	.int	10			// Player Y Resolution (height)
	.int	475			// Player x position
	.int	675			// Player y position
 	.int 	0			// bullet width
	.int 	0			// bullet height
 	.int 	475			// bullet x position
	.int 	675			// bullet y position
	.int	50			// Player HP


Reset:
	.int	50			// Player X Resolution (width)
	.int	10			// Player Y Resolution (height)
	.int	475			// Player x position
	.int	675			// Player y position
 	.int 	0			// bullet width
	.int 	0			// bullet height
 	.int 	475			// bullet x position
	.int 	675			// bullet y position
	.int	50			// Player HP
EndOfReset:				//Dummy label
