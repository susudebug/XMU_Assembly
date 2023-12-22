data segment
    msg1   db 'input a string',13,10,'$'
    table  db 'abcdefghijklmnopqrstuvwxyz','$'
    buffer db 100 dup('$')
    ctrl   db 13,10,'$'
    space  db 20h,'$'
data ends
code segment
           assume ds:data,cs:code
main proc far
    start: 
           mov    ax,data
           mov    ds,ax
 
           lea    dx,msg1
           mov    ah,09
           int    21h

           lea    dx,buffer          ;输入字符
           mov    ah,0ah
           int    21h

           lea    dx,ctrl
           mov    ah,09h
           int    21h
 
    ;lea bx,buffer

           mov    si,0
    loop1: mov    di,0               ;遍历字母表
           mov    al,table[si]

    loop2: mov    cl,buffer[di]      ;遍历输入的字符串
           cmp    cl,al
           je     print1             ;找到了，直接输出该字符
           inc    di
           cmp    buffer[di],'$'
           je     print2
           jmp    loop2

    print1:mov    dl,al
           mov    ah,02h
           int    21h
           inc    si                 ;开始找下一个字符
           cmp    si,26
           jne    loop1
           jmp    exit

    print2:
           lea dx,space
           mov    ah,09h
           int    21h

           inc    si
           cmp    si,26
           jne    loop1
           jmp    exit
        
    exit:  mov    ax,4ch
           int    21h
main endp
code ends
end start