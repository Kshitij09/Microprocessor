section .data
array: dq 0x172845FED217DCC8,0x172845FED21AADCC,0x17B8C5FED217DCC8,0x172845AE0210DC58,0x136745DFEDC2B17D
arr_new: dq 0x00,0x00,0x00,0x00,0x00
colon: db "  :  "
lenC: equ $-colon
msg: db "Data before transfer"
len: equ $-msg
msg2: db "Data after transfer"
len2: equ $-msg2
menu: db "1.Without string",10
	  db "2.With string",10
	  db "Enter your choice: "
lenM: equ $-menu
newline: db 0AH
num: dq 0x172845FED217DCC8

section .bss
result: resb 16
count: resb 1
arr_cnt: resb 1
choice: resb 2

%macro println 2
	mov rax,1
	mov rdi,1
	mov rsi,%1
	mov rdx,%2
	syscall

	mov rax,1
	mov rdi,1
	mov rsi,newline
	mov rdx,1
	syscall
%endmacro

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

	;Printing array before transfer
	println msg,len
	mov rdi,array
	call printarray

	cmp byte[choice],'1'
	je wo_string
	cmp byte[choice],'2'
	je with_string
	jmp exit
	

	print_result:
		println newline,1
		println msg2,len2
		mov rdi,array+16
		call printarray

exit:
	mov rax,60
	mov rdi,0
	syscall

;==================== Procedures ====================

;Without string instruction
wo_string:
	mov rsi,array+32
	mov rdi,array+48
	mov byte[count],05
	up:
		mov rax,qword[rsi]
		mov qword[rdi],rax
		sub rsi,8
		sub rdi,8
		dec byte[count]
	jnz up
jmp print_result

;With string instruction
with_string:
	mov rsi,array+32
	mov rdi,array+48
	mov byte[count],05
	std
	up2:
		movsq
		dec byte[count]
	jnz up2
jmp print_result

;make rdi to point array
printarray:	
	mov byte[arr_cnt],05
	next_num:
		mov rax,rdi
		push rdi				;to preserve rdi value
		mov rsi,result
		call HexToASCII
		print result,16			;to print address
		print colon,lenC
		pop rdi
		mov rax,[rdi]
		push rdi
		mov rsi,result
		call HexToASCII
		println result,16		;to print number
		pop rdi
		add rdi,8
		dec byte[arr_cnt]
	jnz next_num
ret

;Hex to ASCII conversion (16 digit)
;make rax to point source and rsi to destination
HexToASCII:
	mov byte[count],16
	mov rbx,0
	next:
		rol rax,4
		mov bl,al
		and bl,0FH
		cmp bl,09
		jbe skip
		add bl,07
		skip:
			add bl,30H
		mov byte[rsi],bl
		inc rsi
		dec byte[count]
	jnz next
ret