;输入算式计算结果，两个两位十进制数相加或相减，结果如果为负数要输出负号和正确数值
DATA SEGMENT
    MESS1 DB 'PLEASE ENTER:$'
    MESS2 DB 'THE RESULT IS:$'
DATA ENDS

CODE SEGMENT
               ASSUME CS:CODE,DS:DATA,ES:DATA
MAIN PROC FAR
    START:     
               MOV    AX,DATA                    ;初始化
               MOV    DS,AX
               MOV    ES,AX

               SUB    AX,AX
               PUSH   AX

               LEA    DX,MESS1
               PUSH   DX
               CALL   PUTS
               ADD    SP,2

               CALL   DECIBIN                    ;十进制转二进制

    JUDGE:                                       ;判断乘除法
               ADD    AL,30H
               CMP    AL,'*'
               JE     MYMUL
               JMP    MYDIV

    MYMUL:     
               PUSH   BX
               CALL   DECIBIN                    ;获取第二个操作数
               POP    CX                         ;CX为第一个操作数
            
               LEA    DX,MESS2
               PUSH   DX
               CALL   PUTS
               ADD    SP,2

               MOV    AX,CX
               MUL    BX                         ;AX*BX存在AX中
               CALL   DISP

    MYDIV:     
               PUSH   BX
               CALL   DECIBIN                    ;获取第二个操作数
               POP    CX                         ;CX为第一个操作数

               LEA    DX,MESS2
               PUSH   DX
               CALL   PUTS
               ADD    SP,2
                   
               XOR    DX,DX                      ;DX置零
               MOV    AX,CX
               DIV    BX                         ;被除数在DX*10000H+AX  商存在AX中，余数存在DX中

               CALL   DISP
    DISP:      
               CALL   BIN_TO_DEC
               CALL   NLINE
                       
               MOV    AH,4CH
               INT    21H

MAIN ENDP

    ;将AX中的二进制转10进制ASCII码并直接输出
BIN_TO_DEC PROC NEAR
    BEG:       
               MOV    BX,10
               MOV    CX,0
    LAST:      MOV    DX,0
               DIV    BX                         ;(DX,AX)-<(DX,AX)/SRC
               PUSH   DX                         ;余数压站
               INC    CX                         ;统计除法的次数
               CMP    AX,0                       ;商不为0，就继续除
               JNZ    LAST

    AGA:       POP    DX                         ;余数给DX
               ADD    DX,30H                     ;转化为ASCII码
               PUSH   DX
               CALL   PUTC
               ADD    SP,2
               LOOP   AGA
               RET
BIN_TO_DEC ENDP
    ; 从键盘读取十进制转二进制,最后结果存在BX中
DECIBIN PROC NEAR
               MOV    BX, 0                      ; 初始化 BX 寄存器为零
    NEWCHAR:   
               MOV    AH, 1                      ; 设置 AH 为 1，表示从标准输入读取一个字符
               INT    21H                        ; 调用 DOS 中断 21H，读取一个字符到 AL 寄存器

               SUB    AL, 30H                    ; 将 ASCII 字符转换为对应的数字值，'0' 的 ASCII 值为 30H
               JL     EXIT                       ; 若 AL 小于 0，说明输入结束，跳转到 EXIT 结束过程
               CMP    AL, 9D                     ; 若 AL 大于 9，说明输入的不是合法的十进制数字，跳转到 EXIT 结束过程
               JG     EXIT

               CBW                               ; 将 AL 中的无符号数扩展为有符号数，填充 AH 寄存器
               XCHG   AX, BX                     ; 交换 AX 和 BX 寄存器的内容，将当前输入的数字放入 BX 寄存器

               MOV    CX, 10D                    ; 将 CX 寄存器设置为 10，用于后续的乘法操作
               MUL    CX                         ; 乘以 10，结果存放在 AX 寄存器中
               XCHG   AX, BX                     ; 交换 AX 和 BX 寄存器的内容，将乘法结果放入 BX 寄存器
               ADD    BX, AX                     ; 将新的乘法结果与之前的数字相加，结果仍存放在 BX 寄存器中

               JMP    NEWCHAR                    ; 跳转到 NEWCHAR 标签，继续处理下一个输入字符

    EXIT:      
               RET                               ; 过程结束，返回
DECIBIN ENDP



CRLF PROC NEAR
               MOV    DL,0DH
               MOV    AH,02H
               INT    21H
               MOV    DL,0AH
               MOV    AH,02H
               INT    21H
CRLF ENDP
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
CODE ENDS
END START






