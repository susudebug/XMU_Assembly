;8位转ASC码
PUTDB PROC
             PUSH   BP
             MOV    BP,SP
             PUSH   DX
             PUSH   CX
             PUSH   BX
             PUSH   AX

             MOV    BX,[BP-2]
             MOV    CH,02H                     ;设置循环计数器
    ;转化为16进制的ASCII码
    SWITCH:  
             MOV    CL,4H
             ROL    BH,CL                      ;循环左移4位
             MOV    AL,BH                      ;取BX的低8位
             AND    AL,0FH                     ;清除AL的高4位
             ADD    AL,30H                     ;加上"0"的ASCII码
             CMP    AL,39H                     ;将AL的值与"9"的ASCII码比较
             JLE    PRINT
             ADD    AL,07H                     ;若大于9，则+7，转到A~F
      
    ;输出
    PRINT:   
             MOV    DX,00H
             MOV    DL,AL
             PUSH   DX
             CALL   PUTC
             ADD    SP,2

             DEC    CH
             JNZ    SWITCH                     ;如果循环计数器不为0，则跳转到SWITCH
             
             POP    AX
             POP    BX
             POP    CX
             POP    DX
             POP    BP
             RET

PUTDB ENDP