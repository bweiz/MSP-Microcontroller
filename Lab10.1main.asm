;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;	Benton Weizenegger, EELE 371, Lab 10.1
;	2/25/24
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------


init:

;----------	Part 3 Initialize LEDs 1+2 -----------------------------------------

		mov.b		#0000h, &P1SEL0			;Initialize LED1 as output
		mov.b		#0000h, &P1SEL1
		bis.b		#BIT0,  &P1DIR
		bic.b		#BIT0,  &P1OUT

		mov.b		#0000h, &P6SEL0			;Initialize LED2 as output
		mov.b		#0000h, &P6SEL1
		bis.b		#BIT6,  &P6DIR
		bic.b		#BIT6, 	&P6OUT

;-------- Initialize Registers -------------------------------------------------

		mov.w 		#0000h, R4				;Initialize Registers to random values
		mov.w		#2000h, R5
		mov.w		#0000h, R6
		mov.w		#0000h, R8

;--------------- Disable Low Power Mode ----------------------------------------

		bic.b		#LOCKLPM5, &PM5CTL0

main:

;--------- Part 4 Push For loop ------------------------------------------------

		mov.w		#10h, R4			;put 16 into R4 for loop counter
		mov.w		#word1, R5
PushFor:
		push		@R5					;push word.x

		mov.w		@R5+, R8			;increment address R5 and put into R8
		dec			R4
		cmp			#0000h, R4			;compare R4 to zero
		jnz			PushFor					;run for loop until 0
		jz			EndPushFor

EndPushFor:

;---------- Part 5 Pop For Loop -----------------------------------------------

		mov.w		#10h, R4			;16 in R4
		mov.w		#2000h, R8

PopLoop:
		pop			R5					;Pop and place into R8


		jmp			ADD3				;jmp to Add3
AfterSub:
		mov.w		R5, 0(R8)


		add.w		#02h, R8			;Increment R8
		dec			R4
		cmp			#0000h, R4			;Compare, if counter > 0, repeat
		jnz			PopLoop
		jz			EndPopLoop



EndPopLoop:


		jmp 		main

;-------------------------------------------------------------------------------
; ADD3	Subroutine Here
;-------------------------------------------------------------------------------

ADD3:
		add.w		#03h, R5
		jmp			AfterSub

;-------------------------------------------------------------------------------
; Memory Allocation
;-------------------------------------------------------------------------------

		.data
		.retain

DataBlock:
word1:		.short		0000h
word2:		.short		1111h
word3:		.short		2222h
word4:		.short		3333h
word5:		.short		4444h
word6:		.short		5555h
word7:		.short		6666h
word8:		.short		7777h
word9:		.short		8888h
word10:		.short		9999h
word11:		.short		0AAAAh
word12:		.short		0BBBBh
word13:		.short		0CCCCh
word14:		.short		0DDDDh
word15:		.short		0EEEEh
word16:		.short		0FFFFh

			.space 		32


;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
