section .data
emsg: db "Error in opening file",10
lenE: equ $-emsg
newline: db 0AH

section .bss
buffer: resb 100
fdin: resb 8 			;File descriptor 	
bytes: resb 8
filename: resb 100	

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
	pop rbx				;sourcefile name
	pop rbx				;no. of arguments
	pop rbx				;1st argument (filename)

	call get_filename

	fopen filename
	;rax contains file descriptor
	mov qword[fdin],rax

	;to check whether file is opened successfully
	bt rax,63
	jc error

	fread [fdin],buffer,100
	;rax contains no. of bytes read from file
	mov qword[bytes],rax

	;Printing contents of file on terminal
	print buffer,[bytes]

	;Closing the file
	close_file [fdin]
	jmp exit

	error:
		print emsg,lenE
exit:
	mov rax,60
	mov rdi,0
	syscall

;============ Procedures ============
get_filename:
	mov rsi,rbx
	mov rdi,filename
	up:
		mov al,byte[rsi]
		mov byte[rdi],al
		inc rsi
		inc rdi
		cmp al,00
	jne up
ret