section .data
msg: db "Fact("
len: equ $-msg
msg2: db ") = "
len2: equ $-msg2
newline: db 0AH


section .bss
num: resb 1
fact: resb 16
temp: resb 4

%macro print 2
	mov rax,1
	mov rdi,1
	mov rsi,%1
	mov rdx,%2
	syscall
%endmacro

section .text
global _start
_start:
	pop rdx
	pop rdx
	pop rdx
	mov al,byte[rdx]
	mov byte[num],al
	cmp al,39H
	jbe skip
	sub byte[rdx],07H
	skip:
	sub byte[rdx],30H
	
	movzx bx,byte[rdx]
	call factorial

	push rax

	print msg,len
	print num,1
	print msg2,len2

	pop rax
	mov rsi,fact
	call HexToASCII

	print fact,16
	print newline,1

exit:
	mov rax,60
	mov rdi,0
	syscall

;================== Procedures ==================

;recursive function
factorial:
	cmp bl,01
	jne handleStack
	mov rax,01
ret

;explicit stack manipulation
handleStack:
	push rbx
	dec rbx
	call factorial
	pop rbx
	mul rbx
ret

;======== Hex to ASCII conversion (64 bit) ========
HexToASCII:
	;Make rax to point source and rsi to destination
	mov rcx,16
	loop2:
		rol rax,04
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