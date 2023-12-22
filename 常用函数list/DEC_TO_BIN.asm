        ; 从键盘读取十进制转二进制,最后结果存在BX中
DEC_TO_BIN PROC NEAR
                   MOV    BX, 0                                   ; 初始化 BX 寄存器为零
        NEWCHAR:   
                   MOV    AH, 1                                   ; 设置 AH 为 1，表示从标准输入读取一个字符
                   INT    21H                                     ; 调用 DOS 中断 21H，读取一个字符到 AL 寄存器

                   SUB    AL, 30H                                 ; 将 ASCII 字符转换为对应的数字值，'0' 的 ASCII 值为 30H
                   JL     EXIT                                    ; 若 AL 小于 0，说明输入结束，跳转到 EXIT 结束过程
                   CMP    AL, 9D                                  ; 若 AL 大于 9，说明输入的不是合法的十进制数字，跳转到 EXIT 结束过程
                   JG     EXIT

                   CBW                                            ; 将 AL 中的无符号数扩展为有符号数，填充 AH 寄存器
                   XCHG   AX, BX                                  ; 交换 AX 和 BX 寄存器的内容，将当前输入的数字放入 BX 寄存器

                   MOV    CX, 10D                                 ; 将 CX 寄存器设置为 10，用于后续的乘法操作
                   MUL    CX                                      ; 乘以 10，结果存放在 AX 寄存器中
                   XCHG   AX, BX                                  ; 交换 AX 和 BX 寄存器的内容，将乘法结果放入 BX 寄存器
                   ADD    BX, AX                                  ; 将新的乘法结果与之前的数字相加，结果仍存放在 BX 寄存器中

                   JMP    NEWCHAR                                 ; 跳转到 NEWCHAR 标签，继续处理下一个输入字符

        EXIT:      
                   RET                                            ; 过程结束，返回
DEC_TO_BIN ENDP