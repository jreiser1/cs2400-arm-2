numbers	DCD		0xFFFFFFF7, 0x5
result	FILL		4
carry	FILL		4
		
main
		adr		r0,numbers
		ldr		r1,[r0],#4
		ldr		r2,[r0]
		add		r4,r0,#8
		add		r5,r0,#12
		
		
		cmp		r1,#0
		movlt	r6,#1 	;set sign bit, convert to positive
		mvnlt	r1,r1
		addlt	r1,r1,#1
		cmp		r2,#0
		eorlt	r6,r6,#1 	;either or means negative, same means positive
		mvnlt	r2,r2 	;convert to positive
		addlt	r2,r2,#1
		
		stmdb	sp!,{r1,r2}
		bl		mult 	;branch to multiplier
		cmp		r6,#1	;make result positive if negative
		mvneq	r0,r0
		addeq	r0,r0,#1
		str		r0,[r4]
		str		r1,[r5]
		
		end
		
mult
		ldmia	sp!,{r0,r1}	;load op1 and op2
		stmdb	sp!,{r4,r5,r6,r9} ;adding extra registers to the stack
		mov		r2,#1		;shift bit
		mov		r3,#-1		;shift count, has to be negative because of some index weirdness
		mov		r9,#0		;result
		mov		r6,#0		;flag for carry
loop
		cmp		r3,#32		;check if the result is greater than 32 bits
		beq		process
		tst		r0,r2			;test shifting bit against multiplier
		lsl		r2,r2,#1
		add		r3,r3,#1
		beq		loop				;if R3rd bit is zero, loop
		mov		r4,r1			;else mov multiplicand into temp
		lsl		r4,r4,r3			;shift temp R3 bits
		adds		r9,r9,r4			;add into result register, sets flags
		movcs	r6,#1			;set the carry bit if an add ever sets it
		bal		loop				;loop
process
		mov		r0,r9		;store result in return register
		mov		r1,r6
		ldmia	sp!,{r4,r5,r6,r9}
		mov		pc,lr		;branch back to call
		
