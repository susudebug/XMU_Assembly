DATA SEGMENT
    VX      DB 1
    VY      DB 1
    TOP     DB 0
    LEFT    DB 0
    BOTTOM  DB 23
    RIGHT   DB 78
    X       DB 0
    Y       DB 0
    ITIMES  DB 0
    BALLSYM DB 'O'
    RTC_LIM DB 1
DATA ENDS
STACK SEGMENT
          DW  100 DUP(?)
          TOS LABEL WORD
STACK ENDS

CODE SEGMENT
            ASSUME CS:CODE, DS:DATA, SS:STACK, ES:DATA

CLS PROC NEAR
            MOV    AX,3
            INT    10H
            RET
CLS ENDP

PUTC PROC
            PUSH   BP
            MOV    BP,SP
            PUSH   DX
            PUSH   AX

            MOV    DL,[BP-2]
            MOV    AH,02H
            INT    21H

            POP    AX
            POP    DX
            POP    BP
            RET
PUTC ENDP

PUTBALL PROC NEAR
            CALL   CLS

            MOV    AH,02H
            MOV    BH,0
            MOV    DL,X
            MOV    DH,Y
            INT    10H

            MOV    DL,BALLSYM
            PUSH   DX
            CALL   PUTC
            ADD    SP,2

            RET
PUTBALL ENDP

RTC_INT PROC NEAR
            CLI

            PUSH   AX
            PUSH   BX
            PUSH   CX
            PUSH   DX
            PUSH   ES
            PUSH   DS


            INC    ITIMES
            MOV    AL, RTC_LIM
            CMP    ITIMES, AL
            JLE    ENDINT
            MOV    ITIMES, 0

            CLC
            MOV    AL,X
            CMP    AL,RIGHT
            JG     INV_X
            CMP    AL,LEFT
            JL     INV_X
            JMP    NEXT_X
    INV_X:  
            CLC
            NEG    VX
    NEXT_X: 
            CLC
            MOV    AL,VX
            ADC    X,AL

            CLC
            MOV    BL,Y
            CMP    BL,BOTTOM
            JG     INV_Y
            CMP    BL,TOP
            JL     INV_Y
            JMP    NEXT_Y
    INV_Y:  
            CLC
            NEG    VY
    NEXT_Y: 
            CLC
            MOV    AL,VY
            ADC    Y,AL

            CALL   PUTBALL

    ENDINT: 

            POP    DS
            POP    ES
            POP    DX
            POP    CX
            POP    BX
            POP    AX
            
            STI
            IRET
RTC_INT ENDP

MAIN PROC FAR
    START:  
            MOV    AX, DATA
            MOV    DS, AX
            MOV    ES, AX
            MOV    AX, STACK
            MOV    SS, AX
            MOV    SP, TOS

            CALL   CLS

            CLI

            PUSH   DS
            MOV    AX,CODE
            MOV    DS,AX
            LEA    DX,RTC_INT
            MOV    AX,251CH
            INT    21H
            POP    DS

            CALL   PUTBALL

            STI

    LP:     
            HLT
            JMP    LP
MAIN ENDP
CODE ENDS
END START
