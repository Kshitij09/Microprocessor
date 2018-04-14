extern printf
extern scanf

section .data
fmt_img_roots: db "x = %lf + %lfi or ",10,
		   	   db "x = %lf - %lfi",10,0
fmt_rep_roots: db "x = %lf, %lf",10,0		   	   
fmt_real_roots: db "x = %lf or x = %lf",10,0
fmt_in: db "%lf",0
msgA: db "Enter a: "
lenA: equ $-msgA
msgB: db "Enter b: "
lenB: equ $-msgB
msgC: db "Enter c: "
lenC: equ $-msgC
four: dd 04.00

section .bss
cnt: resb 1
A_2: resb 8
A: resq 1
B: resq 1
C: resq 1
root1: resb 8
root2: resb 8
buffer: resb 10
temp: resb 3
tmp: resb 4
delta: resb 8

%macro print 2
	mov rax,1
	mov rdi,1
	mov rsi,%1
	mov rdx,%2
	syscall
%endmacro

%macro mscanf 1
	mov rdi,fmt_in
	mov rax,0
	sub rsp,8
	mov rsi,rsp
	call scanf
	mov r8,qword[rsp]
	mov qword[%1],r8
	add rsp,8
%endmacro

section .text
global main
main:
	call read_coeff

	finit
	;Calculating delta
	fld qword[B]
	fmul st0
	fld qword[A]
	fmul qword[C]
	fmul dword[four]
	fsub
	fst qword[delta]
	mov rax,qword[delta]

	;Case --> Real and repeated roots
	cmp rax,00H
	je rep_roots

	;Case --> Imaginary roots
	bt rax,63
	jc img_roots

	;Case --> Real and distinct roots
	fsqrt
	fst qword[delta]
	fld qword[A]
	fadd qword[A]
	fstp qword[A_2]

	;Calculating first root
	fld qword[B]
	fchs
	fadd
	fdiv qword[A_2]
	fstp qword[root1]

	;Calculating second root
	fld qword[B]
	fchs
	fld qword[delta]
	fsub
	fdiv qword[A_2]
	fstp qword[root2]

	;Printing roots
	mov rdi,fmt_real_roots
	mov rax,2
	sub rsp,8
	movsd xmm0,[root1]
	movsd xmm1,[root2]
	call printf
	add rsp,8

exit:
	mov rax,60
	mov rdi,0
	syscall

;============== Procedures ==============

;Imaginary roots
img_roots:
	fchs
	fsqrt
	fld qword[A]
	fadd qword[A]
	fstp qword[A_2]
	fdiv qword[A_2]
	fst qword[delta]
	fld qword[B]
	fchs
	fdiv qword[A_2]
	fstp qword[B]

	;Printing imaginary root
	mov rdi,fmt_img_roots
	mov rax,4
	sub rsp,8			;Aligning stack pointer
	movsd xmm0,[B]
	movsd xmm1,[delta]
	movsd xmm2,[B]
	movsd xmm3,[delta]
	call printf
	add rsp,8

jmp exit


;Real and repeated roots
rep_roots:
	fld qword[A]
	fadd qword[A]
	fst qword[A_2]
	fld qword[B]
	fchs
	fdiv qword[A_2]
	fst qword[root1]

	;Printing roots
	mov rdi,fmt_rep_roots
	mov rax,2
	sub rsp,8
	movsd xmm0,[root1]
	movsd xmm1,[root1]
	call printf
	add rsp,8

jmp exit

read_coeff:
	;Reading 'a'
	print msgA,lenA
	mscanf A

	;Reading 'b'
	print msgB,lenB
	mscanf B

	;Reading 'c'
	print msgC,lenC
	mscanf C
ret