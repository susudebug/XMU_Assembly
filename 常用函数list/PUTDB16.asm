;16位转ASC码
PUTDB PROC
    PUSH   BP                 
    MOV    BP,SP              

    PUSH   DX                 
    PUSH   CX                 
    PUSH   BX                 
    PUSH   AX                 

    MOV    BX, [BP-2]          ; 从参数中加载一个16位的值到BX寄存器

    MOV    CH, 04H             ; 设置循环次数为4次
SWITCHLAST:
    MOV    CL, 4H              ; 设置每次循环左移的位数为4位
    ROL    BX, CL              ; 将BX寄存器的内容左移4位，通过循环实现
    MOV    AL, BL              ; 将左移后的BX寄存器的低8位加载到AL寄存器
    AND    AL, 0FH             ; 只保留AL寄存器的低4位
    ADD    AL, 30H             ; 将AL寄存器的值加上'0'的ASCII码，转换为字符
    CMP    AL, 3AH             ; 比较AL寄存器的值是否小于ASCII码为'9'的字符
    JL     LAST                ; 如果小于，跳转到LAST标签
    ADD    AL, 07H             ; 如果大于等于'9'，加上7，得到大写字母的ASCII码
LAST:      
    MOV    DX, 00H             ; 清空DX寄存器的值
    MOV    DL, AL              ; 将AL寄存器的值加载到DL寄存器，准备输出
    PUSH   DX                 ; 将DL寄存器的值压入栈
    CALL   PUTC               ; 调用PUTC例程输出字符
    ADD    SP, 2              ; 调整栈指针，清除压入栈的DL寄存器值

    DEC    CH                 ; 循环次数减1
    JNZ    SWITCHLAST         ; 如果循环次数不为零，跳转到SWITCHLAST标签进行下一次循环

    POP    AX                 ; 恢复寄存器AX的值
    POP    BX                 ; 恢复寄存器BX的值
    POP    CX                 ; 恢复寄存器CX的值
    POP    DX                 ; 恢复寄存器DX的值
    POP    BP                 ; 恢复基址寄存器BP的值
    RET                        ; 返回调用者
PUTDB ENDP
