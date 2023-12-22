        ;将AX中的二进制转10进制ASCII码并直接打印
BIN_TO_DEC PROC NEAR
        BEG:      
                   MOV    BX,10
                   MOV    CX,0
        LAST:      MOV    DX,0
                   DIV    BX                                      ;(DX,AX)-<(DX,AX)/SRC
                   PUSH   DX                                      ;余数压站
                   INC    CX                                      ;统计除法的次数
                   CMP    AX,0                                    ;商不为0，就继续除
                   JNZ    LAST

        AGA:       POP    DX                                      ;余数给DX
                   ADD    DX,30H                                  ;转化为ASCII码
                   PUSH   DX
                   CALL   PUTC
                   ADD    SP,2
                   LOOP   AGA
                   RET
BIN_TO_DEC ENDP