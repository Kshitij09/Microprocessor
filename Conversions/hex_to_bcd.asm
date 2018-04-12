section .data
msg: db "Enter 4 digit Hex number: "
len: equ $-msg
res: db "BCD = "
lenR: equ $-res
newline: db 0x0A

section .bss
num: resb 5
count: resb 1
temp: resb 1
num_cnt: resb 1

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
global _start:
_start:
	print msg,len
	read num,5
	print res,lenR
	mov rsi,num
	call HexToBCD	
	print newline,1
	
exit:
	mov rax,60
	mov rdi,0
	syscall

;===================== Procedures =====================

;rsi should point to source
;rax will have final hex number
ASCIItoHex:
	xor rbx,rbx			;initializing to zero 
	xor rax,rax			;initializing to zero 
	mov byte[count],04
	up:
		shl rax,04
		mov bl,byte[rsi]
		cmp bl,39H
		jbe skip
		sub bl,07
		skip:
			sub bl,30H
		add rax,rbx
		inc rsi
		dec byte[count]
	jnz up
ret

HexToBCD:
	call ASCIItoHex
	;rax has hex number
	mov bx,0x0A
	mov byte[num_cnt],0
	next:
		xor dx,dx
		;div instruction stores quotient in rax
		;and remainder in rdx
		div bx
		push dx
		inc byte[num_cnt]
		cmp ax,00
	jne next

	print_bcd:
		pop ax
		add ax,30H
		mov byte[temp],al
		print temp,1
		dec byte[num_cnt]
	jnz print_bcd
ret