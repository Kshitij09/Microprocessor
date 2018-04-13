section .data
msg1: db "Enter First number: "
len1: equ $-msg1
msg2: db "Enter Second number: "
len2: equ $-msg2
res: db "Result = "
lenR: equ $-res
menu: db "1. Successive Addition",10
	  db "2. Add and shift",10
	  db "0. Exit",10
	  db "Enter your choice: "
lenM: equ $-menu
newline: db 0AH
tmp: dw 1234H

section .bss
multiplicand: resb 1
multiplier: resb 1
temp: resb 3
result: resb 4
choice: resb 2

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
	print menu,lenM
	read choice,2

	cmp byte[choice],'1'
	je choice1
	cmp byte[choice],'2'
	je choice2
	cmp byte[choice],'0'
	je exit
jmp _start

exit:
	mov rax,60
	mov rdi,0
	syscall

;To read 2 numbers, covert them to Hex
;and storing as multiplicand and multiplier 
read_numbers:
	print msg1,len1
	read temp,3
	mov rsi,temp
	call ASCIItoHex
	mov [multiplicand],al

	print msg2,len2
	mov word[temp],00H
	read temp,3
	mov rsi,temp
	call ASCIItoHex
	mov [multiplier],al
ret

;================== Successive addition ==================
choice1:
	call read_numbers
	mov al,[multiplicand]
	mov cl,[multiplier]
	xor rbx,rbx				;Initialize to zero
	
	;Check for zero
	cmp cl,00H
	je next3
	
	next:
		add bx,ax
		dec cl
	jnz next
	;Result is in rbx
	next3:
	mov rsi,result
	call HextoASCII

	print res,lenR
	print result,4
	print newline,1
jmp _start

;================== Add and shift ==================
choice2:
	call read_numbers

	mov al,[multiplicand]
	mov cl,[multiplier]
	mov dl,08
	xor rbx,rbx


	next1:
		shr cl,01
		jnc skip2
		add bx,ax
		skip2:
			shl ax,01
			dec dl
	jnz next1

	;Result is in rbx
	mov rsi,result
	call HextoASCII

	print res,lenR
	print result,4
	print newline,1

jmp _start



;Hex to ASCII (4 digit)
;rbx should have hex number
;rsi should point destination
HextoASCII:
	mov rcx,04
	xor rax,rax
	up:
		rol bx,04
		mov al,bl
		and al,0FH
		cmp al,09H
		jbe skip
		add al,07H
		skip:
			add al,30H
		mov byte[rsi],al
		inc rsi
		dec rcx
	jnz up
ret


;=============== ASCII to Hex Conversion (2 digit) ===============
;rsi should point to source
;rax will have final hex number
ASCIItoHex:
	xor rbx,rbx
	xor rax,rax
	mov rcx,02
	up2: 
		shl ax,04
		mov bl,byte[rsi]
		cmp bl,39H
		jbe skip1
		sub bl,07H
		skip1:
			sub bl,30H
		add ax,bx
		inc rsi
		dec rcx
	jnz up2
ret