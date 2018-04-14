section .data
array: dd 10.00, 20.00, 30.00, 40.00, 50.00
dot: db "."
d: dw 100
arr_cnt: dw 5
newline: db 0AH
		  
msg: db "Mean               = "
len: equ $-msg
		
msg1: db 10,"Variance           = "
len1: equ $-msg1
msg2: db 10,"Standard Deviation = "
len2: equ $-msg2

section .bss
cnt: resb 1
mean: resb 4
variance: resb 4
stdeviation: resb 4
buffer: resb 10
temp: resb 2

%macro print 2
	mov rax,1
	mov rdi,1
	mov rsi,%1
	mov rdx,%2
	syscall
%endmacro

%macro read 2
	mov rax,0
	mov rdi,0
	mov rsi,%1
	mov rdx,%2
	syscall
%endmacro

section .text
global _start
_start:
	finit
	
	;==== Mean ====
	fldz
	mov rsi,array
	mov byte[cnt],05H
	next_num:
		fadd dword[rsi]
		add rsi,4
		dec byte[cnt]
	jnz next_num
	fidiv word[arr_cnt]
	fst dword[mean]
	print msg,len
	call display

	;==== Variance ====
	
	mov rsi,array
	mov byte[cnt],05H
	fldz
	up_next:
		fldz
		fadd dword[rsi]
		fsub dword[mean]
		fmul st0
		fadd
		add rsi,4
		dec byte[cnt]
	jnz up_next
	
	fidiv word[arr_cnt]
	fst dword[variance]
	print msg1,len1
	call display

	;==== Standard Deviation ====

	fld dword[variance]
	fsqrt
	print msg2,len2
	call display
	print newline,1
	jmp exit


display:
	fimul word[d] 
	fbstp tword[buffer]
	mov rdi,buffer+9
	mov byte[cnt],9
	up:
		mov al,byte[rdi]
		mov rsi,temp
		call bToA
		push rdi
		print temp,2
		pop rdi
		dec rdi
		dec byte[cnt]
	jnz up
	push rdi
	print dot,1
	pop rdi
	mov al,byte[rdi]
	mov rsi,temp
	call bToA
	print temp,2
ret


bToA:
	mov rcx,02H
	loop3:
		rol al,04
		mov dl,al
		and dl,0FH
		add dl,30H
		mov byte[rsi],dl
		inc rsi
	loop loop3
ret
;======== Hex to ASCII conversion (2 digit) ========
HexToASCII:
	;Make rax to point source and rsi to destination
	;mov rax,number
	mov rcx,02H
	loop2:
		rol al,04
		mov dl,al
		and dl,0FH
		cmp dl,09H
		jbe add_30
		add dl,07H
	add_30:
		add dl,30H
		mov byte[rsi],dl
		inc rsi
		dec rcx
		jnz loop2
ret

exit:
	mov rax,60
	mov rdi,0
	syscall