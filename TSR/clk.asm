.MODEL TINY
.286                        ;This directive enables real mode 80286 instructions
ORG 100H                    ;originating address of code segment (Hex of 256)


CODE SEGMENT
     ;Assigning logical name to segment
     ASSUME CS:CODE,DS:CODE,ES:CODE 
        OLD_IP DW 00        ;To hold the old base address
        OLD_CS DW 00        ;To hold the old offset
JMP INIT

MY_TSR:
        PUSH AX             ;store all contents of register to preserve original values
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
        PUSH ES

        MOV AX,0B800H		;address of Video RAM
        MOV ES,AX           ;setting es to beginning of display ram
        MOV DI,3650         ;setting offset to use in display ram

        MOV AH,02H			;For character output
        INT 1AH				;Get time from BIOS chip
        ;CH=Hrs, CL=Mins, DH=Sec 					
        MOV BX,CX

        ;BCD to ASCII Conversion
        MOV CL,2
LOOP1:  ROL BH,4
        MOV AL,BH
        AND AL,0FH
        ADD AL,30H
        ;BI BBB FFFF == < Blinking > < RGB > < IRGB > 
        MOV AH,06H          ; 0 000 0100 = BI BBB FFFF  --> (Red on Black)
        MOV ES:[DI],AX
        INC DI
        INC DI
        DEC CL
        JNZ LOOP1

        MOV AL,':'
        MOV AH,86H
        MOV ES:[DI],AX
        INC DI
        INC DI

        MOV CL,2
LOOP2:  ROL BL,4
        MOV AL,BL
        AND AL,0FH
        ADD AL,30H
        MOV AH,06H
        MOV ES:[DI],AX
        INC DI
        INC DI
        DEC CL
        JNZ LOOP2

        MOV AL,':'
        MOV AH,86H
        MOV ES:[DI],AX

        INC DI
        INC DI

        MOV CL,2
        MOV BL,DH

LOOP3:  ROL BL,4
        MOV AL,BL
        AND AL,0FH
        ADD AL,30H
        MOV AH,06H
        MOV ES:[DI],AX
        INC DI
        INC DI
        DEC CL
        JNZ LOOP3

        POP ES
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX

        JMP MY_TSR

INIT:
        MOV AX,CS			;Initialize data
        MOV DS,AX

        CLI					;Clear Interrupt Flag

        ;get interrupt vector from IVT
        MOV AH,35H			
        MOV AL,08H          ;interrupt no. 08 --> for timer
        INT 21H

        MOV OLD_IP,BX       ;(base) -> is saved to temporary location
        MOV OLD_CS,ES       ;(offset) -> is saved to temporary location

        MOV AH,25H			;Set new Interrupt vector for out own ISR
        MOV AL,08H          ;interrupt no. 08 --> for timer
        ;old address was ES:BX now it is DS:DX
        LEA DX,MY_TSR       ;new address for interrupt
        INT 21H

        MOV AH,31H			;Make program Transient
        MOV DX,OFFSET INIT  ;size of program
        STI                 ;Set interrupt flag
        INT 21H

CODE ENDS

END