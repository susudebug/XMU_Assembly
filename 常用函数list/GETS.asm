GETS PROC
             PUSH   BP
             MOV    BP,SP
             PUSH   DX
             PUSH   AX

             MOV    DX,[BP-2]
             MOV    AH,0AH                     ;接受输入字符串
             INT    21H

             POP    AX
             POP    DX
             POP    BP
             RET
GETS ENDP