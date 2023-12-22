; Table Search

datasg segment para 'data'
    mess1   db      'stock number? ', 13, 10, '$'    ; 字符串，包括回车换行符和字符串结束符(10,13)
            stoknin label byte                       ; 程序中特定位置的标识符，而不是用来存储数据的变量。

    ;max和stockin没有直接关联
    max     db      3                                ; 限制输入的最大位数(含回车)，不可删除
    act     db      ?                                ; 用户的操作数，用于判断是否退出程序
    stokn   db      3 dup(?)                         ; 设置一个长度为3的数组，用于存储输入

    ;若设max=5，stokn=3。从键盘输入2700，stokn阶段到27\n，则可以找到Processors

    stoktab db      '05','  Excavators'              ; 表格记录：
            db      '08','  Lifters   '
            db      '09','  Presses   '
            db      '12','  Valves    '
            db      '23','  Processors'
            db      '27','  Pumps     '              ; 股票号码 '27' 对应的描述 'Pumps'

    descrn  db      14 dup(20h), 13, 10, '$'         ; 这声明了一个数组，用于存储从表格中找到的描述。数组的大小是14字节，初始化为ASCII空格(20h)，然后包括回车符(13)、换行符(10)和字符串结束符('$')
    mess    db      'Not in table! ', '$'            ; 没有找到对应股票


code segment
          assume cs:code, ds:datasg, es:datasg

main proc far                                     ;far远调用，意味着可以从其他段调用它

    ;在程序运行前将数据段和附加段做初始化
          push   ds
          sub    ax, ax
          push   ax
          mov    ax, datasg
          mov    ds, ax
          mov    es, ax

    ;标志程序开始
    start:
    ;显示字符串
          lea    dx, mess1
          mov    ah, 09
          int    21h
    
          lea    dx, stoknin                      ;将地址跳转到stoknin指定的位置
          mov    ah, 0Ah                          ;从键盘获取字符
          int    21h                              ;等待用户输入股票号码，存入stokn数组

          cmp    act, 0                           ;比较0和act的值
          je     exit                             ;若act=0，即没有输入则

          mov    al, stokn                        ;将stokn的第一个字节(低位)加载到al
          mov    ah, stokn+1                      ;将 stokn 的第二个字节（高位）加载到 ah 中。
    ;
          mov    cx, 06                           ;将06存入循环计数寄存器'cx'中, 下一个loop指令将循环6次
          lea    si, stoktab                      ;将 stoktab 的地址加载到源变址寄存器 si 中
    
    ;找匹配
    a20:  
          cmp    ax, word ptr [si]                ;将 ax 与 si 指向的字进行比较。其中word ptr关键字指出其为16位字
          je     a30                              ;相等跳转到a30
          add    si, 14                           ;将 si 增加 14，以移动到下一个库存号。
           
          loop   a20                              ;循环

          lea    dx, mess                         ;没找到，显示'Not in table! '
          mov    ah, 09                           ;用于调用字符串显示功能
          int    21h
          jmp    exit

    ;匹配成功后输出对应股票代码和名称
    a30:  
          mov    cx, 07                           ;包含股票号码和一个空格
          lea    di, descrn                       ;将 descrn 的地址加载到目的变址寄存器 di 中。
          rep    movsw                            ;重复将 cx 个字（双字节）从 si 复制到 di，然后 cx 减 1，直到 cx 等于零。

          lea    dx, descrn                       ;将 descrn 的地址加载到 dx 中
          mov    ah, 09                           ;用于调用 DOS 的显示字符串功能。
          int    21h                              ;显示 descrn 中的字符串
          jmp    start                            ;跳转到 start 标签，继续下一轮的输入。

    exit: 
          ret
main endp
code ends
             end     main
