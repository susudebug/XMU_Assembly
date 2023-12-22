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