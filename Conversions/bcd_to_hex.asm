section .data
msg: db "Enter 5 digit BCD number: "
len: equ $-msg
res: db "Hex = "
lenR: equ $-res
newline: db 0x0A

section .bss
num: resb 6
count: resb 1
factor: resb 4
result: resb 8

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
	print msg,len
	read num,6
	print res,lenR
	call BCDtoHex
	mov rsi,result+7
	call HexToASCII
	print result,8
	print newline,1
exit:
	mov rax,60
	mov rdi,0
	syscall

;================= Procedures =================

;Result will be stored in rbx
BCDtoHex:
	;starting from end of number
	mov rsi,num+4
	xor rbx,rbx
	xor rax,rax
	mov byte[count],5
	;Initially factor will be 1, but it will 
	;increment in multiples of 10
	mov dword[factor],1
	up:
		mov eax,00
		mov al,byte[rsi]
		sub al,30H
		mul dword[factor]
		add ebx,eax
		mov eax,0x0A
		mul dword[factor]
		mov dword[factor],eax
		dec rsi
		dec byte[count]
	jnz up
ret

;rbx has Hex number
;rsi should point to destination
HexToASCII:
	xor rax,rax
	mov byte[count],8
	next:
		mov al,00
		mov al,bl
		and al,0FH
		cmp al,09H
		jbe skip
		add al,07
		skip:
		add al,30H
		mov byte[rsi],al
		ror rbx,04
		dec rsi
		dec byte[count]
	jnz next
ret