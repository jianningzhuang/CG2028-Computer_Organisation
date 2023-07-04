/*
 * LPC1769_asm_basic : asm.s
 * CK Tham, ECE, NUS
 * June 2011
 *
 * Simple assembly language program to compute
 * ANSWER = A*B + C*D
 */

@ Directives
		.thumb                  @ (same as saying '.code 16')
	 	.cpu cortex-m3
		.syntax unified
	 	.align 2

@ Equates
        .equ STACKINIT,   0x10008000

@ Vectors
vectors:
        .word STACKINIT         @ stack pointer value when stack is empty
        .word _start + 1        @ reset vector (manually adjust to odd for thumb)
        .word _nmi_handler + 1  @
        .word _hard_fault  + 1  @
        .word _memory_fault + 1 @
        .word _bus_fault + 1    @
        .word _usage_fault + 1  @
	    .word 0            		@ checksum

		.global _start

@ Start of executable code
.section .text

_start:

@ code starts
@ Calculate ANSWER = A*B + C*D = 13000
	LDR R1, B
	MOV R0, #1
	MOV R2, #0

@ Loop at the end to allow inspection of registers and memory
loop:
	LSRS R3, R1, R0
	IT CS
	ADDCS R2, #1
	LSL R2, R2, #1
	ADDS R0, #1
	CMP R0, #32
	BLE loop
	STR R2, [R1]

@ Loop if any exception gets triggered
_exception:
_nmi_handler:
_hard_fault:
_memory_fault:
_bus_fault:
_usage_fault:
        b _exception

@ Define constant values
A:
	.word 7
B:
	.word 127
C:
	.word 20
D:
	.word 400
@ Store result in SRAM (4 bytes)
	.lcomm	ANSWER	4
	.end
