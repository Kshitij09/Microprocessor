extern scanfile
section .data
global spc_cnt,line_cnt,char_cnt
spc_cnt: db 0
line_cnt: db 0
char_cnt: db 0
file_name: db "sample.txt",0	;0 Helps in searching of file
msg: db "File opened successfully"
len: equ $-msg
msg1: db "Error in opening file"
len1: equ $-msg1
msgs: db 10d,"Number of spaces: "
lens: equ $-msgs
msgl: db 10d,"Number of lines: "
lenl: equ $-msgl
msgc: db 10d,"Enter character to search: "
lenc: equ $-msgc
msgch: db 10d,"Number of character occurance: "
lench: equ $-msgch
msgCon: db "Contents of file: "
lenCon: equ $-msgCon
newline: db 0AH

section .bss
global buffer,buf_len,fd,length,char
buffer: resb 100		; Buffer to read file contents
fd: resb 8				; File descriptor
length: resb 8
char: resb 2

;Opening file
;This will open file and store file descriptor
; value to rax
%macro fopen 1
	mov rax,2			;open
	mov rdi,%1			;filename
	mov rsi,2			;opening mode - RW
	mov rdx,0777		;permissions
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

;Reading from file
;returns no. of bytes read from file in rax
%macro fread 3
	mov rax,0		;read
	mov rdi,%1		;file descriptor
	mov rsi,%2		;destination to store file contents(buffer)
	mov rdx,%3		;default buffer length
	syscall
%endmacro

;close file
%macro close_file 1
mov rax,3			;close
mov rdi,%1			;file descriptor
syscall
%endmacro

section .text
global _start
_start:

	fopen file_name
	;rax contains file descriptor
	mov qword[fd],rax
	;Testing whether file is opened successfully
	bt rax,63
	jnc msg_opened
		print msg1,len1
		jmp next
	msg_opened:
		print msg,len

	next:
	fread [fd],buffer,100
	;rax contains no. of bytes read from file
	mov [length],rax

	;Printing contents of file on terminal
	print newline,1
	print msgCon,lenCon
	print newline,1
	print buffer,[length]

	print msgc,lenc
	read char,2

	;Calling extern procedure
	call scanfile
	close_file [fd]

	print msgs,lens
	print spc_cnt,1
	print msgl,lenl
	print line_cnt,1
	print msgch,lench
	print char_cnt,1
	print newline,1 
exit:
	mov rax,60
	mov rdi,0
	syscall	