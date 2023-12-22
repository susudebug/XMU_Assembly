DATA SEGMENT
       SLENMAX  DB 32                     ; 输入字符串的最大长度
       SLEN     DB ?                      ; 输入字符串的长度
       STR      DB 32 DUP(?)              ;存储输入字符串的缓冲区，设置为大小为32的数组

       MSGINPUT DB 'Input String:$'
       MSGLET   DB 'Letters:$'
       MSGCOUNT DB 'Digits:$'
       MSGOTHER DB 'Other:$'

       LETTER   DW 0                      ;字母计数器
       DIGIT    DW 0                      ;数字计数器
       OTHER    DW 0                      ;其他字符计数器
DATA ENDS

CODE SEGMENT
              ASSUME CS:CODE, ES:DATA, DS:DATA
       ;输出单个字符
PUTC PROC
              PUSH   BP                              ;暂存BP
              MOV    BP,SP                           ;设置BP为当前栈基指针
              PUSH   DX                              ;暂存DX
              PUSH   AX                              ;暂存AX

        
              MOV    DL,[BP-2]                       ;获取传入的参数，保存到DL
              MOV    AH,02H                          ;输出单个字符
              INT    21H                             ;显示字符

              POP    AX                              ;恢复AX
              POP    DX                              ;恢复DX
              POP    BP                              ;恢复BP
              RET
PUTC ENDP
       ;输出以$结尾的字符串
PUTS PROC
              PUSH   BP                              ;暂存BP
              MOV    BP,SP                           ;设置BP为当前栈基指针
              PUSH   DX                              ;暂存DX
              PUSH   AX                              ;暂存AX
  
              MOV    DX,[BP-2]                       ;获取传入的参数，保存到DL
              MOV    AH,09H                          ;输出字符串
              INT    21H                             ;显示字符

              POP    AX                              ;恢复AX
              POP    DX                              ;恢复DX
              POP    BP                              ;恢复BP
              RET
PUTS ENDP
       ;从输入获取字符串
GETS PROC
              PUSH   BP
              MOV    BP,SP
              PUSH   DX
              PUSH   AX

    
              MOV    DX,[BP-2]
              MOV    AH,0AH                          ;从键盘获取字符
              INT    21H                             ;等待输入

              POP    AX
              POP    DX
              POP    BP
              RET
GETS ENDP
       ;将16位二进制转为16进制的ASCII码
PUTDB PROC
              PUSH   BP
              MOV    BP,SP
              PUSH   DX
              PUSH   CX
              PUSH   BX
              PUSH   AX


              MOV    BX,[BP-2]
              MOV    CH,04H                          ;设置循环计数器
       ;转化为16进制的ASCII码
       SWITCH:
              MOV    CL,4H
              ROL    BX,CL                           ;循环左移4位
              MOV    AL,BL                           ;取BX的低8位
              AND    AL,0FH                          ;清除AL的高4位
              ADD    AL,30H                          ;加上"0"的ASCII码
              CMP    AL,39H                          ;将AL的值与"9"的ASCII码比较
              JLE    PRINT
              ADD    AL,07H                          ;若大于9，则+7，转到A~F
      
       ;输出
       PRINT: 
              MOV    DX,00H
              MOV    DL,AL
              PUSH   DX
              CALL   PUTC
              ADD    SP,2

              DEC    CH
              JNZ    SWITCH                          ;如果循环计数器不为0，则跳转到SWITCH
             
              POP    AX
              POP    BX
              POP    CX
              POP    DX
              POP    BP
              RET


PUTDB ENDP
       ;换行回车
NLINE PROC
              PUSH   BP
              MOV    BP,SP
              PUSH   DX

              MOV    DX,0DH                          ;回车
              PUSH   DX
              CALL   PUTC
              ADD    SP,2

              MOV    DX,0AH                          ;换行
              PUSH   DX
              CALL   PUTC
              ADD    SP,2

              POP    DX
              POP    BP
              RET
NLINE ENDP
MAIN PROC FAR
       START: 
       ;初始化
              MOV    AX,DATA
              MOV    DS,AX
              MOV    ES,AX

              LEA    DX,MSGINPUT
              PUSH   DX
              CALL   PUTS
              ADD    SP,2
        
              LEA    DX,SLENMAX
              PUSH   DX
              CALL   GETS
              ADD    SP,2

              LEA    SI,STR
              CLD                                    ; 清除方向标志寄存器，设置为向前移动
       BEGIN: 
              LODSB
              CMP    AL,0DH                          ;检查是否为回车键
              JE     NEXT

              CMP    AL,30h                          ; 检查是否小于'0'
              JC     OTH                             ; 如果是，它是“其他”字符
              CMP    AL,3ah                          ; 检查是否小于':'
              JC     NUM                             ; 如果是，它是数字
              CMP    AL,41h                          ; 检查是否小于'A'
              JC     OTH                             ; 如果是，它是“其他”字符
              CMP    AL,5bh                          ; 检查是否小于'['
              JC     LET                             ; 如果是，它是字母
              CMP    AL,61h                          ; 检查是否小于'a'
              JC     OTH                             ; 如果是，它是“其他”字符
              CMP    AL,7bh                          ; 检查是否小于'{'
              JC     LET                             ; 如果是，它是字母
       OTH:   
              INC    OTHER
              JMP    BEGIN
       NUM:   
              INC    DIGIT
              JMP    BEGIN

       LET:   
              INC    LETTER
              JMP    BEGIN
    
       NEXT:  
       ;输出消息1--'Letters:$'
              CALL   NLINE
              LEA    DX,MSGLET
              PUSH   DX
              CALL   PUTS
              ADD    SP,2
            
              MOV    DX,LETTER
              PUSH   DX
              CALL   PUTDB
              ADD    SP,2                            ;回栈

              CALL   NLINE
       ;输出消息2--'Digits:$'
              LEA    DX,MSGCOUNT
              PUSH   DX
              CALL   PUTS
              ADD    SP,2

              MOV    DX,DIGIT
              PUSH   DX
              CALL   PUTDB
              ADD    SP,2

              CALL   NLINE
       ;输出消息3--'Other:$'
              LEA    DX,MSGOTHER
              PUSH   DX
              CALL   PUTS
              ADD    SP,2

              MOV    DX,OTHER
              PUSH   DX
              CALL   PUTDB
              ADD    SP,2

              CALL   NLINE
       EXIT:  
              MOV    AH,4CH
              INT    21H
MAIN ENDP
CODE ENDS
END MAIN