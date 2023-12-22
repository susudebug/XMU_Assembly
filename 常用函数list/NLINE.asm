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