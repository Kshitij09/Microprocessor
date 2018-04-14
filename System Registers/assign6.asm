section .data
	op_mode: db 10,"Processor operation mode: "
	len_op_mode: equ $-op_mode 
	msg_real: db "Real mode",10
	len_real: equ $-msg_real
	msg_pr: db "Protected mode",10
	len_pr: equ $-msg_pr
	msw_contents: db 10,"Machine status word: "
	len_msw: equ $-msw_contents
	gdtr_contents: db 10,"GDTR: "
	len_gdtr: equ $-gdtr_contents
	ldtr_contents: db 10,"LDTR: "
	len_ldtr: equ $-ldtr_contents
	idtr_contents: db 10,"IDTR: "
	len_idtr: equ $-idtr_contents
	tr_contents: db 10,"TR: "
	len_tr: equ $-tr_contents
	newline: db 10d
section .bss
cr0_data: resd 1
gdtr: resd 1 
	  resw 1
ldtr: resw 1
idtr: resd 1 
	  resw 1
tr: resw 1
temp: resb 4

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
	;Store GDTR (48 bit)
	sgdt [gdtr]
	;Store LDTR (16 bit)
	sldt [ldtr]
	;Store IDTR (48 bit)
	sidt [idtr]
	;Store TR (16 bit)
	str [tr]
	
	;Store Machine Status Word (32 bit) 
	smsw eax
	mov [cr0_data],eax

	print op_mode,len_op_mode
	;Checking PE bit of MSW
	bt eax,1
	jc print_protected
		print msg_real,len_real
		jmp exit

	print_protected:
		print msg_pr,len_pr

	print msw_contents,len_msw
	;MSW is of 32 bits, i.e. 8 digits
	;hence we need to print last 4 digits first and then first 4 digits
	mov rax,[cr0_data+2]
	mov rsi,temp
	call HexToASCII
	print temp,4

	mov rax,[cr0_data]
	mov rsi,temp
	call HexToASCII
	print temp,4

	print gdtr_contents,len_gdtr
	;GDTR is of 48 bits, i.e. 12 digits
	;printing  last 4 digits, then prior 4 and then first 4 
	mov rax,[gdtr+4]
	mov rsi,temp
	call HexToASCII
	print temp,4

	mov rax,[gdtr+2]
	mov rsi,temp
	call HexToASCII
	print temp,4

	mov rax,[gdtr]
	mov rsi,temp
	call HexToASCII
	print temp,4

	print idtr_contents,len_idtr
	;IDTR is of 48 bits, i.e. 12 digits
	;printing  last 4 digits, then prior 4 and then first 4 
	mov rax,[idtr+4]
	mov rsi,temp
	call HexToASCII
	print temp,4

	mov rax,[idtr+2]
	mov rsi,temp
	call HexToASCII
	print temp,4

	mov rax,[idtr]
	mov rsi,temp
	call HexToASCII
	print temp,4

	print ldtr_contents,len_ldtr
	mov rax,[ldtr]
	mov rsi,temp
	call HexToASCII
	print temp,4

	print tr_contents,len_tr
	mov rax,[tr]
	mov rsi,temp
	call HexToASCII
	print temp,4

	print newline,1	
	jmp exit


;======== Hex to ASCII conversion ========
HexToASCII:
	;Make rax to point source and rsi to destination
	;mov rax,number
	mov rcx,04H
	loop2:
		rol ax,04
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