 	.syntax unified
 	.cpu cortex-m3
 	.thumb
 	.align 2
 	.global	classification
 	.thumb_func

@ CG2028 Assignment, Sem 2, AY 2021/22
@ (c) CG2028 Teaching Team, ECE NUS, 2021

@ student 1: Name: Zhuang Jianning, Matriculation No.: A0214561M
@ student 2: Name: Vikas Harlani, Matriculation No.: A0214360U

@Register map
@R0 - N, returns class
@R1 - points
@R2 - label
@R3 - sample
@R4 - current_distance
@R5 - current_class
@R6 - px
@R7 - py
@R8 - sx
@R9 - sy
@R10 - loop counter
@R11 - nearest_distance
@R12 - nearest_class

classification:
@ PUSH / save (only those) registers which are modified by your function
@ parameter registers need not be saved.
		PUSH {R1-R12, R14}
@ write asm function body here

		@initialise counter in for loop
		MOV R10, R0 @0b0000,0001,1010,0000,1010,0000,0000,0000 = 0x01A0A000

		@load sample[0] into sx
		LDR R8, [R3], #4 @0b0000,0100,1001,0011,1000,0000,0000,0100 = 0x04938004
		@load sample[1] into sy
		LDR R9, [R3] @0b0000,0101,1001,0011,1001,0000,0000,0000 = 0x05939000


distance_loop:

		@load points[2*i] into px
		LDR R6, [R1], #4 @0b0000,0100,1001,0001,0110,0000,0000,0100 = 0x04916004
		@load points[2*i+1] into py
		LDR R7, [R1], #4 @0b0000,0100,1001,0001,0111,0000,0000,0100 = 0x04917004

		@calculate (px-sx) and store back in R6
		SUB R6, R6, R8 @0b0000,0000,0100,0110,0110,0000,0000,1000 = 0x00466008
		@calculate (px-sx)^2 and store back in R6
		MUL R6, R6, R6 @0b0000,0000,0000,0000,0110,0110,0001,0110 = 0x00006616
		@calculate (py-sy) and store back in R7
		SUB R7, R7, R9 @0b0000,0000,0100,0111,0111,0000,0000,1001 = 0x00477009
		@calculate (py-sy)^2 and store back in R7
		MUL R7, R7, R7 @0b0000,0000,0000,0000,0111,0111,0001,0111 = 0x00007717

		@store result in current_distance
		ADD R4, R6, R7 @0b0000,0000,1000,0110,0100,0000,0000,0111 = 0x00864007
		@load class of current point into current_class
		LDR R5, [R2], #4 @0b0000,0100,1001,0010,0101,0000,0000,0100 = 0x04925004

		@compare current counter i and N
		CMP R10, R0 @0b0000,0001,0101,1010,0000,0000,0000,0000 = 0x015A0000
		@if equal, then initialise nearest distance and nearest class with values from point[0]
		IT EQ
		BLEQ INITIALISE

		@compare current_distance with current_nearest
		CMP R4, R11 @0b0000,0001,0101,0100,0000,0000,0000,1011 = 0x0154000B
		@if lesser than, then update nearest distance and class with current distance and current class
		IT LT
		BLLT UPDATE

		@decrement counter i
		SUBS R10, R10, #1 @0b0000,0010,0101,1010,1010,0000,0000,0001 = 0x025AA001
		@compare counter to continue loop
		BGT distance_loop @0b1100,1000,0000,0000,0000,0000,0011,1000 = 0xC8000038


@ prepare value to return (class) to C program in R0
@ the #5 here is an arbitrary result
		@move nearest class to R0 to be returned
		MOV R0, R12 @0b0000,0001,1010,0000,0000,0000,0000,1100 = 0x01A0000C
@ POP / restore original register values. DO NOT save or restore R0. Why?
		POP {R1-R12, R14}
@ return to C program
		BX	LR

@ you could write your code without SUBROUTINE
INITIALISE:

		@initialise nearest_distance with distance of point[0]
		MOV R11, R4 @0b0000,0001,1010,0000,1011,0000,0000,0100 = 0x01A0B004
		@initialise nearest_class with class of point[0]
		MOV R12, R5 @0b0000,0001,1010,0000,1100,0000,0000,0101 = 0x01A0C005
		@return to loop
		BX LR

UPDATE:
		@update new nearest distance
		MOV R11, R4 @0b0000,0001,1010,0000,1011,0000,0000,0100 = 0x01A0B004
		@update nearest_class
		MOV R12, R5 @0b0000,0001,1010,0000,1100,0000,0000,0101 = 0x01A0C005
		@return to loop
		BX LR


@label: .word value

@.lcomm label num_bytes

