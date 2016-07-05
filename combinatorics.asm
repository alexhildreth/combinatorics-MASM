TITLE Combinatorics     (combinatorics.asm)

; Author:	Alex Hildreth
; CS271     Date: 12/5/14
; Description: creates combinatorics problems and presents them to the user
;			   The user provides an answer, and the program calculates the
;			   correct answer to compare it to. Tells the user if they were
;			   right or wrong, and asks if they wish to go again.

INCLUDE Irvine32.inc

MAXRAND		equ	12
MINRAND		equ	3

;WriteString Macro
;Adapted from Lecture 26
;**************************************
mWriteStr MACRO buffer
	push	edx
	mov		edx, buffer
	call	WriteString
	pop		edx
ENDM
;**************************************


.data

;string variables
;***********************************************************************
	intro		BYTE "My name is Alex, and welcome to Cominatorics Practice!",0
	inst1		BYTE "I will provide you with the number of elements in",0
	inst2		BYTE "a set and how many from the set can be chosen for",0
	inst3		BYTE "a subset. You can then answer how many combinations",0
	inst4		BYTE "are possible. I will tell you if you are right or wrong.",0
	prompt		BYTE "Enter your answer: ",0
	space		BYTE " ",0		
	ans1		BYTE "There are ",0
	ans2		BYTE " combinations of ",0
	ans3		BYTE " items from a set of ",0	
	rightAns	BYTE "Nice job!",0
	wrongAns	BYTE "You were incorrect.",0
	goAgain		BYTE "Go again? [y]es [n]o: ",0
	period		BYTE ".",0
	numElements	BYTE "Number of elements: ",0
	sizeSubset	BYTE "Size of subset: ",0
	badInput	BYTE "Bad input! Try again.",0
	answer		BYTE 21 DUP(0)
	again		BYTE 21 DUP(0)

	testStr		BYTE "123",0
;***********************************************************************

;numeric variables
;***********************************************************************
	answerInt	DWORD	0
	result		DWORD	0
	n			DWORD	?
	r			DWORD	?
;***********************************************************************


.code
main PROC

	;set random seed
	call	Randomize

	;introduce program. Passes all strings as offsets
	push	OFFSET	intro
	push	OFFSET	inst1
	push	OFFSET	inst2
	push	OFFSET	inst3
	push	OFFSET	inst4
	call	introduction

	;game loop
	gameLoop:
	call	CrLf
	call	CrLf

	;generate and show the problem
	;passes the offset of n and r
	push	OFFSET	n
	push	OFFSET	r
	push	OFFSET	numElements
	push	OFFSET	sizeSubset
	call	showProblem

	;get the answer
	;pass @prompt @badInput and @answerInt
	push	OFFSET  badInput
	push	OFFSET	prompt
	push	OFFSET	answerInt
	call	GetData

	;calculate the answer
	;store in result
	;passes values of n and r, and @result
	push	n
	push	r
	push	OFFSET result
	call	Combinations

	;show the results and whether the user was correct
	push	OFFSET period
	push	OFFSET ans1
	push	OFFSET ans2
	push	OFFSET ans3
	push	OFFSET rightAns
	push	OFFSET wrongAns
	push	n
	push	r
	push	result
	push	answerInt
	call	showResults

	;go again?
	call		CrLf
	mWriteStr	OFFSET goAgain
	mov			edx, OFFSET again
	mov			ecx, SIZEOF again
	call		ReadString
	mov			al, [again] ;move ascii code into eax
	cmp			eax, 121    ;compare to code for 'y'
	je			gameLoop

	exit	; exit to operating system
main ENDP

;********Additional Procedures:********

;introduction procedure
;introduces program and instructs user
;**************************************
introduction PROC
	push	ebp
	mov		ebp, esp
	;save registers
	push	eax
	push	ebx
	push	ecx
	push	edx

	mWriteStr [ebp+24]
	call	CrLf
	mWriteStr [ebp+20]
	call	CrLf
	mWriteStr [ebp+16]
	call	CrLf
	mWriteStr [ebp+12]
	call	CrLf
	mWriteStr [ebp+8]
	call	CrLf
	call	CrLf

	;restore registers
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp
	ret		20
introduction ENDP
;**************************************

;show problem procedure
;generates the problem and presents it to the user
;**************************************
showProblem PROC
	push	ebp
	mov		ebp, esp
	;save registers
	push	eax
	push	ebx
	push	ecx
	push	edx

	;generate size n MINRAND - MAXRAND
		mov		eax, MAXRAND
		sub		eax, MINRAND
		inc		eax
		call	RandomRange
		add		eax, MINRAND
	;store in n
		mov		ebx, [ebp+20]
		mov		[ebx], eax
	;present to user
		mWriteStr	[ebp+12]
		call		WriteInt
		call		CrLf
	;generate subset size
		call	RandomRange
		inc		eax
	;move into r
		mov		ebx, [ebp+16]
		mov		[ebx], eax
	;present to user
		mWriteStr	[ebp+8]
		call		WriteInt
		call		CrLf
	
	;restore registers
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop	ebp
	ret	16
showProblem ENDP
;**************************************

;get data procedure
;gets the users answer as a string, turns 
;the string into and int, and returns both
;**************************************
GetData	PROC
	push	ebp
	mov		ebp, esp
	;save registers
	push	eax
	push	ebx
	push	ecx
	push	edx

	;jump over error message
	jmp		firstLoop

	;bad input message
	BadInp:
	;reset answerInt
	mov		eax, [ebp+8]
	mov		ebx, 0
	mov		[eax], ebx
	call	CrLf
	call	CrLf
	mWriteStr	[ebp+16]
	call	CrLf
	call	CrLf

	firstLoop:
	;prompt answer
	mWriteStr	[ebp+12]
	mov			edx, OFFSET answer
	mov			ecx, SIZEOF answer
	call		ReadString
	
	;Loop through answer array to generate an int
	mov		ecx, 0 ;loop count
	L1:
	;increase array to proper index
	mov		ebx, OFFSET answer
	add		ebx, ecx
	mov		al, [ebx] 

	;make sure in range and not end of string
	cmp		eax, 0
	je		endLoop
	cmp		eax, 48
	jl		BadInp
	cmp		eax, 57
	ja		BadInp

	;call calcInt on this step
	push	[ebp+8]
	push	eax
	call	calcInt

	;increase loop count and loop back
	inc		ecx
	jmp		L1
	 	

	endLoop:
	;restore registers
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp
	ret		12
GetData	ENDP
;**************************************

;calcInt procedure
;called from within get data procedure
;calculates each step in conversion from string to int
;**************************************
calcInt	PROC
	push	ebp
	mov		ebp, esp
	;save registers
	push	eax
	push	ebx
	push	ecx
	push	edx

	;move current int answer into eax
	mov		edx, [ebp+12]
	mov		eax, [edx]

	;multiply by 10
	mov		ebx, 10
	mul		ebx

	;subtract 48 from current string value
	mov		ebx, [ebp+8]
	sub		ebx, 48

	;combine for updated answer
	add		eax, ebx

	;update answerInt

	mov		ebx, [ebp+12]
	mov		[ebx], eax

	;restore registers
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp
	ret		8
calcInt	ENDP
;**************************************


;Combinations procedure
;calculates the correct answer and stores in result
;**************************************
Combinations PROC
	push	ebp
	mov		ebp, esp
	;save registers
	push	eax
	push	ebx
	push	ecx
	push	edx

	;get n!
	push	[ebp+16]
	push	[ebp+8]
	call	Factorial
	mov		edx, [ebp+8]
	mov		eax, [edx]
	;n! now in eax

	;get r!
	push	[ebp+12]
	push	[ebp+8]
	call	Factorial
	mov		edx, [ebp+8]
	mov		ebx, [edx]
	;r! now in ebx

	;get (n-r)!
	mov		ecx, [ebp+16]
	mov		edx, [ebp+12]
	sub		ecx, edx
	;n-r now in ecx
	push	ecx
	push	[ebp+8]
	call	Factorial
	mov		edx, [ebp+8]
	mov		ecx, [edx]
	;(n-r)! now in ecx

	;check if result was zero, in which case the answer is 1
	cmp		ecx, 0
	jne		notZero
	mov		ecx, 1
	mov		edx, [ebp+8]
	mov		[edx], ecx
	jmp		endComb

	notZero:
	;calculate result
	push	eax		;n!
	push	ebx		;r!
	push	ecx		;(n-r)!
	;r! * (n-r)!
	pop		eax		;(n-r)!
	pop		ebx		;r!
	mul		ebx		;r! * (n-r)! now in eax
	mov		edx, 0
	mov		ecx, eax 
	pop		eax		;n!
	div		ecx

	;move into result
	mov		edx, [ebp+8]
	mov		[edx], eax


	endComb:
	;restore registers
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp
	ret		12
Combinations ENDP
;**************************************


;Factorial procedure
;accepts a number and a result location and
;calculates the factorial
;**************************************
Factorial PROC
	push	ebp
	mov		ebp, esp
	;save registers
	push	eax
	push	ebx
	push	ecx
	push	edx

	;set up loop
	mov		eax, [ebp+12]
	mov		ebx, [ebp+12]
	mov		ecx, [ebp+12]

	;check if zero (if n-r is zero)
	;if so, return 0 as a result
	cmp		ecx, 0
	jne		doCalc
	mov		eax, 0
	mov		ebx, [ebp+8]
	mov		[ebx], eax
	jmp		endFact

	doCalc:
	;calculate factorial
	L1:
	mov		edx, 0
	mul		ebx
	loop	L1
	;factorial now in eax

	;return result
	mov		ebx, [ebp+8]
	mov		[ebx], eax

	endFact:
	;restore registers
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp
	ret		8
Factorial ENDP	
;**************************************


;show results procedure
;shows the result and tells user if they were
;correct or incorrect
;**************************************
showResults PROC
	push	ebp
	mov		ebp, esp
	;save registers
	push	eax
	push	ebx
	push	ecx
	push	edx

	;show right answer
	call		CrLf
	call		CrLf
	mWriteStr	[ebp+40]
	mov			eax, [ebp+12]
	call		WriteInt
	mWriteStr	[ebp+36]
	mov			eax, [ebp+16]
	call		WriteInt
	mWriteStr	[ebp+32]
	mov			eax, [ebp+20]
	call		WriteInt
	call		CrLf

	;check if user's answer was correct
	mov		eax, [ebp+8]
	mov		ebx, [ebp+12]
	cmp		eax, ebx
	je		correct
	;if not correct
	mWriteStr	[ebp+24]
	call		CrLf
	jmp			endResults

	correct:
	mWriteStr	[ebp+28]
	call		CrLf
	
	endResults:
	;restore registers
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp
	ret		40
showResults ENDP
;**************************************


END main