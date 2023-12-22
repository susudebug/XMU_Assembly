;打印以$结尾的字符串
PUTS PROC
             PUSH   BP
             MOV    BP,SP
             PUSH   DX
             PUSH   AX

             MOV    DX,[BP-2]
             MOV    AH,09H                     ;输出字符串
             INT    21H

             POP    AX
             POP    DX
             POP    BP
             RET
PUTS ENDP