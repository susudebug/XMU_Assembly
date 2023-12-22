;输入关键词、句子，判断是否匹配，以及匹配的位置
DATA SEGMENT
    INPUT_KEY      DB 'Enter keyword:$'
    INPUT_SENTENCE DB 'Enter Sentence:$'
    NOT_MATCH      DB 'No match.$'
    MATCH1         DB 'Match at location: ','$'
    MATCH2         DB 'H of the sentence$'

    SLENMAX        DB 32                           ; 输入字符串的最大长度
    SLEN           DB ?                            ; 有无字符串
    STR            DB 32 DUP(?)                    ;存储输入字符串的缓冲区，设置为大小为32的数组
    
    WORDMAX        DB 32                           ; 输入字符串的最大长度
    WLEN           DB ?                            ; 有无字符串
    WTR            DB 32 DUP(?)                    ;存储输入字符串的缓冲区，设置为大小为32的数组
      

DATA ENDS
CODE SEGMENT
             ASSUME CS:CODE,ES:DATA,DS:DATA
PUTC PROC
             PUSH   BP                         ; 保存调用者的基指针
             MOV    BP,SP                      ; 设置当前栈帧的基指针
             PUSH   DX                         ; 保存 DX 寄存器的值
             PUSH   AX                         ; 保存 AX 寄存器的值

             MOV    DL,[BP-2]                  ; 从栈中获取函数参数，即要输出的字符，存储在 DL 中
             MOV    AH,02H                     ; 将 DOS 功能号设置为 02H，表示字符输出
             INT    21H                        ; 调用 DOS 中断 21H，进行字符输出

             POP    AX                         ; 恢复 AX 寄存器的值
             POP    DX                         ; 恢复 DX 寄存器的值
             POP    BP                         ; 恢复调用者的基指针
             RET                               ; 返回到调用者
PUTC ENDP
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
    ;将8位二进制转为16进制的ASCII码---因为SLEN和WLEN都是一字节数据，不会超过8位
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

MAIN PROC FAR
    WORD:    
             MOV    AX,DATA
             MOV    DS,AX
             MOV    ES,AX

        
             LEA    DX,INPUT_KEY
             PUSH   DX
             CALL   PUTS
             ADD    SP,2
        
             LEA    DX,WORDMAX
             PUSH   DX
             CALL   GETS
             ADD    SP,2

             CALL   NLINE
    SENTENCE:
             LEA    DX,INPUT_SENTENCE
             PUSH   DX
             CALL   PUTS
             ADD    SP,2
        
             LEA    DX,SLENMAX
             PUSH   DX
             CALL   GETS
             ADD    SP,2
             CALL   NLINE
             CLD
    BEGIN:   
    ;如果句子长度小于关键词
             MOV    DH,SLEN
             MOV    DL,WLEN
             CMP    DH,DL
             JL     N_MATCH


             MOV    CX,0                       ;清0
             MOV    CH,SLEN                    ;循环计数器
             MOV    SI,0
             MOV    DI,0
             MOV    AL,0                       ;关键词指标
             MOV    AH,0                       ;标记关键词在句子中的位置
    ;如果大于关键词
    CMP_IN:  
    ;注意：CMP不能写成 CMP WTR[DI],STR[SI]
             LEA    BX,WTR
             MOV    DH,[BX+DI]
             CMP    DH,STR[SI]
             JNE    CMP_OUT                    ;如果不等，跳转CMP_OUT

             INC    AL
             INC    SI
             INC    DI
             INC    AH
             DEC    CH

             CMP    AL,WLEN
             JE     MATCH

             CMP    AH,SLEN
             JG     N_MATCH
             JNZ    CMP_IN                     ;如果循环记数器CX不为0，则循环
    ;如果不相等
    CMP_OUT: 
             CMP    DI,0                       ;如果第一个词就对不上
             JE     LOOP_E

             MOV    DI,0
             MOV    AL,0

             JNZ    CMP_IN                     ;如果循环记数器CX不为0，则循环

    LOOP_E:  
             INC    SI
             INC    AH
             JNZ    CMP_IN
    N_MATCH: 
             LEA    DX,NOT_MATCH
             PUSH   DX
             CALL   PUTS
             ADD    SP,2
             CALL   NLINE
             JMP    SENTENCE
    ; JMP    EXIT
    MATCH:   
             LEA    DX,MATCH1
             PUSH   DX
             CALL   PUTS
             ADD    SP,2

             SUB    AH,WLEN
             ADD    AH,1
             MOV    DX,AX
             PUSH   DX
             CALL   PUTDB
             ADD    SP,2

             LEA    DX,MATCH2
             PUSH   DX
             CALL   PUTS
             ADD    SP,2

             CALL   NLINE
             JMP    SENTENCE
    ; JMP    EXIT
    EXIT:    
             MOV    AH,4CH
             INT    21H
MAIN ENDP
CODE ENDS
END MAIN