upper		DCD		0xFFFFFFFF, 0x00000000
lower		DCD		0xFFFFFFFB, 0x82481248
rwidth		EQU		32
result		FILL		8        ;only need 8 bytes for 64 bit result
carry		FILL		4
			
			
main
			adr		r0,upper
			ldr		r1,[r0],#4
			ldr		r3,[r0],#4
			ldr		r2,[r0],#4
			ldr		r4,[r0]
			mov		r5,#0
			;if		the number is negative, convert it to positive
			cmp		r1,#0
			movlt	r5,#1
			mvnlt	r1,r1
			mvnlt	r2,r2
			addslt	r2,r2,#1
			bge		skip		;the carry flag is set by the cmp, addcs doesnt prevent that
			addcs	r1,r1,#1
			
getMSB
			ldmia	sp!,{r0}
			stmdb	sp!,{lr}
			mov		r1,r0
			mov		r2,#0
			
bit
			cmp		r2, #rwidth
			beq		getMSBreturn
			lsls		r1,r1,#1
			addcc	r2,r2,#1
			bcc		bit		;branches only if carry is 0
			
getMSBreturn
			rsbs		r2,r2, #rwidth
			mov		r0,r2
			ldmia	sp!,{Lr}
			mov		pc,lr
			
mult
			ldmia	sp!,{r0,r1,r2,r3}
			stmdb	sp!,{r4,r5,r6,r7,r8,r9,r10,lr}
			
			mov		r4,#1    ;shift bit
			mov		r5,#-1    ;shift counter
			mov		r6,#0    ;result registers
			mov		r7,#0
			mov		r8,#0    ;logical shift left mask
			mov		r9,#0    ;multiplicand_lower MSB
			stmdb	sp!,{r0,r1,r2,r3}    ;store caller save registers on the stack
			stmdb	sp!,{r3}            ;multiplicand lower as parameter
			bl		getMSB            ;call getMSB
			mov		r9,r0            ;save into r9
			ldmia	sp!,{r0,r1,r2,r3}    ;load caller save registers from the stack
			
multloop
			add		r5,r5,#1		;keeps looping until r5 matches the width
			cmp		r5, #rwidth
			bge		multupper		;multiply upper when r5 matches width
			;is		the muliplier set at that bit, if so continue, else loop
			tst		r1,r4,lsl r5
			beq		multloop
			
			;multiplicand	lower -> shifter -> added to result, with overflow added to r7
			;get		the bits that overflow
			;shift	index + MSB_index - rwidth = # of bits that overflow
			;create	mask such that MSB-# of bits are set to 1
			add		r10,r5,r9
			cmp		r10, #rwidth
			blt		multloweradd
			sub		r10,r10,#rwidth
			
			mov		r10,r4,lsl r10    ;00...1..00 -1 => 0000
			sub		r8,r10,#1        ;00...0..11
			mov		r10,r5        ;shift_index - 32
			rsb		r10,r10,#rwidth
			lsl		r8,r8,r10        ;r8 has the mask
			and		r8,r8,r3        ;and it with the lower multiplicand
			lsr		r8,r8,r10        ;shift the overflow bits down to 0
			add		r7,r7,r8        ;add them to the "overflow" i.e. upper return register
			
multloweradd
			;multplicaton	upper -> shifter -> added to r7, if overflow here -> set carry flag
			;invert	the mask
			add		r6,r6,r3, lsl r5    ;add the lower bits, err but c-bit gets set by the lsl,
			;addcs	r7,r7,#1            ;add the carry to the upper if it occurs
			add		r7,r7,r2, lsl r5    ;add the upper shifted over, if it overflows, then set "carry" memory
			adrcs	r10,carry
			strcs	r4,[r10]
			mov		r8,#0		;reset mask
			bal		multloop
			
multupper
			cmp		r5,#64	;branch to return/finish operation once result is incremented/calculated
			beq		multreturn
			sub		r9,r5,#rwidth
			;if		the upper multiplier bit is set at the index, then add, else loop again
			tst		r0,r4,lsl r9
			beq		multloop
			;the		lower multiplicand is lsl index-32 and added into upper result (r7)
			add		r7,r7,r3,lsl r9
			adrcs	r10,carry
			strcs	r4,[r10]
			;if		the upper multiplicand has any and bits set, they are shifted into overflow, dont need to add
			cmp		r2,#0
			adrne	r10,carry
			strne	r4,[r10]
			bal		multloop
			
multreturn
			mov		r0,r7
			mov		r1,r6
			ldmia	sp!,{r4,r5,r6,r7,r8,r9,r10,lr}
			mov		pc,lr
			
skip
			;same	for op2
			cmp		r3,#0
			eorlt	r5,r5,#1
			mvnlt	r3,r3
			mvnlt	r4,r4
			addslt	r4,r4,#1
			stmdb	sp!,{r1,r2,r3,r4}
			bl		mult
			adr		r2,result
			cmp		r5,#1
			mvneq	r0,r0
			mvneq	r1,r1
			addseq	r1,r1,#1
			str		r0,[r2],#4
			str		r1,[r2]
			
			end
