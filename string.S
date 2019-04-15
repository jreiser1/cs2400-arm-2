chars0	DCD		'T', 'h', 'e', ' ', '2', '0', '1', '8', ' ', 'T', 'u'
chars1	DCD		'r', 'i', 'n', 'g', ' ', 'A', 'w', 'a', 'r', 'd', ' '
chars2	DCD		'w', 'a', 's', ' ', 'a', 'w', 'a', 'r', 'd', 'e', 'd'
chars3	DCD		' ', 't', 'o', ' ', 'B', 'e', 'n', 'g', 'i', 'o'
chars4	DCD		' ', 'H', 'i', 'n', 't', 'o', 'n', ' ', 'a', 'n'
chars5	DCD		'd', ' ', 'L', 'e', 'C', 'u', 'n', 'n', ' ', 'f', 'o'
chars6	DCD		'r', ' ', 't', 'h', 'e', 'i', 'r', ' ', 'w', 'o', 'r'
chars7	DCD		'k', ' ', 'o', 'n', ' ', 'n', 'e', 'u', 'r', 'a', 'l'
chars8	DCD		'n', 'e', 't', 'w', 'o', 'r', 'k', 's', '.'
count	DCD		95
countb	EQU		24
string	FILL		24
		
		mov		r0,#0
		adr		r1, chars0
		adr		r6, string
loop
		cmp		r0,#countb
		beq		exit		;branch to exit method when each char is stored
		ldmia	r1!,{r2,r3,r4,r5}
		lsl		r2,r2,#24
		add		r2,r2,r3,lsl #16
		add		r2,r2,r4,lsl #8
		add		r2,r2,r5
		stmia	r6!,{r2}
		add		r0,r0,#1
		bal		loop
exit
		mov		r0,#0
		str		r0,[r6]
		end
