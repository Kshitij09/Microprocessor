section .data
filename: db "Hello.txt",0		;0 helps in searching of file
newtext: db 10,"**This line is appended to file by the program"
len: equ $-newtext
newline: db 0AH

section .bss
buffer: resb 100
fdin: resb 8 			;File descriptor 	
bytes: resb 8	

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

	;Printing contents of file on terminal
	print buffer,[bytes]

	;Write new data to file
	fwrite [fdin],newtext,len

	;Closing the file
	close_file [fdin]

exit:
	mov rax,60
	mov rdi,0
	syscall