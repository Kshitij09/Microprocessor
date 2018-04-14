section .data
emsg: db "Error in opening file",10
len: equ $-emsg
emsg2: db "Error: invalid opcode",10
len2: equ $-emsg2
msgC: db "File copied successfully...",10
lenC: equ $-msgC
msgD: db "File deleted...",10
lenD: equ $-msgD
newline: db 0AH

section .bss
buffer: resb 100
fdin: resb 8 			;File descriptor 	
bytes: resb 8
filename: resb 100
filename2: resb 100

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

%macro delete_file 1
	mov rax,87
	mov rdi,%1
	syscall
%endmacro

section .text
global _start
_start:
	pop rbx				;no. of arguments
	pop rbx				;sourcefile name 
	pop rbx				;1st argument (opcode)

	cmp byte[rbx],'t'
	je case_type
	cmp byte[rbx],'c'
	je case_copy
	cmp byte[rbx],'d'
	je case_delete
	
	;do not match with any case (invalid opcode)
	print emsg2,len2
	jmp exit

	

	error:
		print emsg,len
exit:
	mov rax,60
	mov rdi,0
	syscall

;============ Procedures ============
get_filename:
	mov rsi,rbx
	mov rdi,filename
	up:
		movsb
		cmp byte[rsi],00
	jne up
ret

get_filename2:
	mov rsi,rbx
	mov rdi,filename2
	up2:
		movsb
		cmp byte[rsi],00
	jne up2
ret

;Type - Read the contents of file and display it on terminal
case_type:
	pop rbx				;filename
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

;Copy - Copy the contents of file1 to file2
case_copy:
	pop rbx				;file1
	call get_filename

	pop rbx				;file2
	call get_filename2

	;========== opening and reading first file ==========
	fopen filename
	;rax contains file descriptor
	mov qword[fdin],rax

	;to check whether file is opened successfully
	bt rax,63
	jc error

	fread [fdin],buffer,100
	;rax contains no. of bytes read from file
	mov qword[bytes],rax

	close_file [fdin]

	;========== opening second file ==========
	fopen filename2

	;rax contains file descriptor
	mov qword[fdin],rax

	;to check whether file is opened successfully
	bt rax,63
	jc error

	;writing buffer from file1 to file2
	fwrite [fdin],buffer,[bytes]

	print msgC,lenC

	close_file [fdin]
jmp exit

case_delete:
	pop rbx
	call get_filename

	fopen filename
	;rax contains file descriptor
	mov qword[fdin],rax

	;to check whether file is opened successfully
	bt rax,63
	jc error

	delete_file filename

	print msgD,lenD

jmp exit