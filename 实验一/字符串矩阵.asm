
CODE SEGMENT
          ASSUME CS:CODE

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

NLINE PROC
          PUSH   BP
          MOV    BP,SP
          PUSH   DX

          MOV    DX,0DH
          PUSH   DX
          CALL   PUTC
          ADD    SP,2

          MOV    DX,0AH
          PUSH   DX
          CALL   PUTC
          ADD    SP,2

          POP    DX
          POP    BP
          RET
NLINE ENDP

EMPTY PROC
          PUSH   BP
          MOV    BP,SP
          PUSH   DX
          PUSH   CX

          MOV    CX,02H
    SHOW: 
          MOV    DX,0H
          PUSH   DX
          CALL   PUTC
          ADD    SP,2
          LOOP   SHOW

          POP    CX
          POP    DX
          POP    BP
          RET
EMPTY ENDP

MAIN PROC FAR
    START:
          MOV    DL,10H
          MOV    BL,0FH       ;15

    ROW:  
          MOV    CX,10H       ;16
    LINE: 

          PUSH   DX
          CALL   PUTC
          ADD    SP,2

          CALL   EMPTY

          INC    DL
          LOOP   LINE
    
          CALL   NLINE
    
          DEC    BL
          CMP    BL,0H
          JNE    ROW
          JE     EXIT

    EXIT: 
          MOV    AH,4CH
          INT    21H

MAIN ENDP

CODE ENDS
    END MAIN
