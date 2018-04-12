section .data
section .bss
section .text

exit:
	mov rax,60
	mov rdi,0
	syscall