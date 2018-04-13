extern spc_cnt,line_cnt,char_cnt
extern buffer,buf_len,fd,length,char

section .text
global scanfile
scanfile:
	mov rsi,buffer
	mov al,byte[char]
	mov rcx,[length]
	loop1:
		cmp byte[rsi],20H
		je case_space
		cmp byte[rsi],0AH
		je case_newline
		cmp byte[rsi],al
		je case_char
		next:
			inc rsi
			dec rcx
	jnz loop1
	jmp conv_ASCII
case_space:
	inc byte[spc_cnt]
	jmp next

case_newline:
	inc byte[line_cnt]
	jmp next

case_char:
	inc byte[char_cnt]
	jmp next


;============= Converting counts to ASCII =============
conv_ASCII:
	cmp byte[spc_cnt],09H
	jbe skip
	add byte[spc_cnt],07H
	skip:
		add byte[spc_cnt],30H

	cmp byte[line_cnt],09H
	jbe skip2
	add byte[line_cnt],07H
	skip2:
		add byte[line_cnt],30H

	cmp byte[char_cnt],09H
	jbe skip3
	add byte[char_cnt],07H
	skip3:
		add byte[char_cnt],30H		
ret