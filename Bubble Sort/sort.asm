section .data
fmt: db "%lf",10,0
filename: db "numbers.txt",0		;0 helps in searching of file
msgS: db "Sorted Numbers:",10
lenS: equ $-msgS
newline: db 0AH
space: db 20H
array: db 00H

section .bss
buffer: resb 100
fdin: resb 8 			;File descriptor 	
bytes: resb 8
temp: resb 1
count: resb 8
cnt: resb 8	

;to open a file
;returns file descriptor in rax
%macro fopen 1
	mov rax,2			;open system call
	mov rdi,%1			;file name
	mov rsi,2			;opening mode
	mov rdx,0777		;permissions
	syscall
%endmacro

;to read from file
;return no. of bytes read from file in rax
%macro fread 3
	mov rax,0			;read system calll
	mov rdi,%1			;file descriptor
	mov rsi,%2			;destination to store file contents(Buffer)
	mov rdx,%3			;default buffer length
	syscall
%endmacro

%macro fwrite 3
	mov rax,1			;write system call
	mov rdi,%1			;file descriptor
	mov rsi,%2			;data buffer to be written
	mov rdx,%3			;length of buffer
	syscall
%endmacro

;close file
%macro close_file 1
	mov rax,3			;close
	mov rdi,%1			;file descriptor
	syscall
%endmacro

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
	fopen filename
	;rax contains file descriptor
	mov qword[fdin],rax

	fread [fdin],buffer,100
	;rax contains no. of bytes read from file
	mov qword[bytes],rax
	xor rax,rax

	;Printing contents of file on terminal
	print buffer,[bytes]

	call copy_numbers


	;Bubble sort
	xor rcx,rcx
	xor rdx,rdx
	xor rbx,rbx
	mov rcx,qword[count]		;i
	mov rcx,qword[count]		;j
	dec rcx						;i-1
	dec rdx						;j-1
	loopI:
		mov rsi,array
		mov rdi,array+1
		mov rdx,rcx
		loopJ:
			mov al,byte[rsi]
			mov bl,byte[rdi]
			br1:
			cmp al,bl
			jbe incrJ
			;need to swap
			mov byte[rsi],bl
			mov byte[rdi],al
			incrJ:
				inc rsi
				inc rdi
				dec rdx
		jnz loopJ
		dec rcx
	jnz loopI

	;Writing sorted array to file
	call write_array

	;Closing the file
	close_file [fdin]

exit:
	mov rax,60
	mov rdi,0
	syscall

;==================== Procedures ====================
copy_numbers:
	xor rcx,rcx
	mov rsi,buffer
	mov rdi,array
	mov rcx,qword[bytes]
	xor rdx,rdx						;to count numbers
	up:
		;Checking whether it's a number
		cmp byte[rsi],'0'
		jb next
		cmp byte[rsi],'9'
		ja next
		inc rdx					
		mov al,byte[rsi]
		mov byte[rdi],al
		inc rdi

		next:
		inc rsi
		dec rcx
	jnz up
	mov qword[count],rdx
ret

;Procedure to write sorted array with spaces into file
write_array:
	xor rcx,rcx
	fwrite [fdin],msgS,lenS
	mov rsi,array
	mov rax,qword[count]
	mov qword[cnt],rax
	up2:
		mov al,byte[rsi]
		mov byte[temp],al
		push rsi
		fwrite [fdin],temp,1
		fwrite [fdin],space,1
		pop rsi
		inc rsi
		dec qword[cnt]
	jnz up2
ret