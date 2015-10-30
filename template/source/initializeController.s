.globl initializeController
initializeController:
	
//initialize controller clock (11)
	push 	{lr}	
	ldr 	r10, =0x20200004	//address of clock pin
	ldr 	r1, [r10]
	mov 	r2, #7
	lsl 	r2, #3
	bic 	r1, r2 
	mov 	r3, #1
	lsl 	r3, #3
	orr 	r1, r3
	str 	r1, [r10]
//initialiaze controller latch (9)
	ldr 	r10, =0x20200000 	//address of latch pin
	ldr 	r1, [r10]
	mov 	r2, #7
	lsl 	r2, #27
	bic 	r1, r2 
	mov 	r3, #1
	lsl 	r3, #27
	orr 	r1, r3
	str 	r1, [r10]
//initialize controller data (10)
	ldr 	r10, =0x20200004	//address of data pin
	ldr 	r1, [r10]
	mov 	r2, #7
	bic 	r1, r2 
	str 	r1, [r10]
	pop 	{lr}
	bx 	lr

//writing to gpio line 9 = latch line
// r1 is the value to write
.global writeLat
writeLat:
	push 	{lr}
	mov 	r10, #9
	ldr 	r2, = 0x20200000
	mov 	r3, #1
	lsl 	r3, r10
	teq 	r1, #0
	streq 	r3, [r2, #40]
	strne 	r3, [r2, #28]
	pop 	{lr}
	bx 	lr

//writing to gpio line 11 = clock line
// r1 is the value to write
.global writeClk
writeClk:
	push 	{lr}
	mov r10, #11
	ldr r2, =0x20200000
	mov r3, #1
	lsl r3, r10
	teq r1, #0
	streq 	r3, [r2, #40]
	strne 	r3, [r2, #28]
	pop 	{lr}
	bx	lr

//reading to gpio line 10 = data line
// r1 is the value to read
.global readSNES
readSNES:
	push 	{r11, lr}
	mov 	r10, #10	
	ldr 	r11, = 0x20200000
	ldr 	r1, [r11, #52]
	mov 	r3, #1
	lsl 	r3, r10
	and 	r1, r3
	teq	r1, #0
	moveq 	r1, #0
	movne 	r1, #1
	pop 	{r11, lr}
	bx 	lr

//waitloop on controller clock 
//input: r3 time to wait
.global waitFunction
waitFunction:
	push	{lr}
	ldr 	r10, =0x20003004
	ldr 	r1, [r10]
	add 	r1, r3
waitLoop:
	ldr 	r2, [r10]
	cmp 	r1, r2
	bhi 	waitLoop
	pop	{lr}
	bx	lr

.section .data
.align 4
font:		.incbin	"font.bin"


