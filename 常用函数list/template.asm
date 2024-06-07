stack segment
    db 255 dup(?)
stack ends

; 声明样例
data segment
    input_string label byte
        max_length      db  100
        true_length     db  ?
        string          db  100 dup(?)
    arr         db      26 dup(0)
    arr_len     db      26
data ends

code segment
    assume cs:code, ss:stack, ds:data
; 输出十进制AX(无符号)
print_dec proc far
        push bx
        push cx
        push dx
        xor cx, cx
        mov bl, 10
    while_p:
        div bl          ; al = ax / bl; ah = ax % bl
        mov dl, ah
        add dl, '0'
        push dx
        inc cx
        xor ah, ah

        cmp al, byte ptr 0
        jnz while_p

        mov ah, 02h
    while_o:
        pop dx
        int 21h
        loop while_o

        pop dx
        pop cx
        pop bx
        ret
print_dec endp
; 输出二进制AX(无符号)
print_bin proc far
        push cx
        push dx
        mov cx, 16
    while_pb:
        mov dx, ax
        and dx, 1
        add dl, '0'
        shr ax, 1
        push dx
        loop while_pb

        mov cx, 16
        mov ah, 02h
    while_ob:
        pop dx
        int 21h
        loop while_ob

        pop dx
        pop cx
        ret
print_bin endp
; 输出十六进制AX(无符号) 大写
print_hex proc far
        push cx
        push dx
        mov cx, 4
    while_ph:
        mov dx, ax
        and dx, 15
        add dl, '0'
        cmp dl, '9'
        jle l_10
        add dl, 7
    l_10:
        push cx
        mov cl, 4
        shr ax, cl
        pop cx
        push dx
        loop while_ph

        mov cx, 4
        mov ah, 02h
    while_oh:
        pop dx
        int 21h
        loop while_oh

        pop dx
        pop cx
        ret
print_hex endp
; 输出换行
endl proc far
        push ax
        push dx
        mov ah, 02h
        mov dl, 0ah
        int 21h
        pop dx
        pop ax
        ret
endl endp
; 输出DL(字符)
putchar proc far
        push ax
        mov ah, 02h
        int 21h
        pop ax
        ret
putchar endp
; 输出DX(字符串) '$'=结束
puts proc far
        push ax
        mov ah, 09h
        int 21h
        pop ax
        ret
puts endp
; 输入AL(字符)
getchar proc far
        mov ah, 01h
        int 21h
        ret
getchar endp
; 输入DX(字符串) DX[0]=最大容量 DX[1]=实际容量 DX[2]=字符串首
gets proc far
        push ax
        mov ah, 0ah
        int 21h
        pop ax
        ret
gets endp
; 排序数组(BYTE)(小->大) CX:排序的长度(容量) BX:数组首项地址 选择排序
sortsb proc far
    push ax
    push si
    push di

    xor si, si                      ; si = 0
    _sorts_for1:
        mov di, si
        inc di                      ; di = si + 1
        push si                     ; save si (let si := minIndex)
        _sort_for2:
            mov al, [bx+si]
            cmp al, [bx+di]         ; if bx[minIndex] > bx[di] 
            jle _sort_for2_end
            mov si, di              ; then minIndex = di

        _sort_for2_end:
            inc di
            cmp di, cx              ; if di <= cx loop inner
            jl _sort_for2

        mov di, si                  ; di := minIndex
        pop si                      ; si := current
        cmp di, si
        je _sorts_for1_end          ; if di != si
        mov al, [bx+di]             ; then swap
        xchg al, [bx+si]
        mov [bx+di], al

    _sorts_for1_end:
        inc si                      ; si++
        mov ax, cx
        dec ax
        cmp si, ax                  ; if si < cx - 1 loop outer
        jl _sorts_for1
        
    pop di
    pop si
    pop ax
    ret
sortsb endp
; 排序数组(WORD)
sortsw proc far
    push ax
    push si
    push di

    xor si, si                      ; si = 0
    _sortsw_for1:
        mov di, si
        add di, 2                   ; di = si + 1
        push si                     ; save si (let si := minIndex)
        _sortsw_for2:
            mov ax, [bx+si]
            cmp ax, [bx+di]         ; if bx[minIndex] > bx[di] 
            jle _sortsw_for2_end
            mov si, di              ; then minIndex = di

        _sortsw_for2_end:
            add di, 2
            mov ax, cx
            shl ax, 1
            cmp di, ax              ; if di <= cx loop inner
            jl _sortsw_for2

        mov di, si                  ; di := minIndex
        pop si                      ; si := current
        cmp di, si
        je _sortsw_for1_end         ; if di != si
        mov ax, [bx+di]             ; then swap
        xchg ax, [bx+si]
        mov [bx+di], ax

    _sortsw_for1_end:
        add si, 2                   ; si++
        mov ax, cx
        dec ax
        shl ax, 1
        cmp si, ax                  ; if si < cx - 1 loop outer
        jl _sortsw_for1
        
    pop di
    pop si
    pop ax
    ret
sortsw endp

; bx
process proc far
    xor ax, ax
    mov al, [bx]
    sub al, '0'
    push bx
    mov bl, 10
    mul bl
    pop bx
    push cx
    mov cl, [bx+1]
    sub cl, '0'
    add al, cl
    pop cx
    ret
process endp

start:
    mov ax, stack
    mov ss, ax
    mov ax, data
    mov ds, ax

    ; CODE EXAMPLE
    ; TODO: 

    lea dx, input_string
    call gets

    lea bx, string
    call process
    mov cx, ax
    add bx, 3
    call process
    xchg ax, cx

    mov dl, [bx-1]
    cmp dl, '+'
    je add_l
    sub ax, cx
    jmp pnt
    add_l:
        add ax, cx
    pnt:
        push ax

        mov cx, 5
        lea bx, string
    forward:
        mov dl, [bx]
        call putchar
        inc bx
        loop forward

        mov dl, '='
        call putchar
        pop ax

        cmp ax, 0
        jg pnt_n
        push ax
        mov dl, '-'
        call putchar
        pop ax
        neg ax
    pnt_n:
        call print_dec
    ; CODE END

    mov ax, 4c00h
    int 21h
code ends
end start

; 108E
; masm xxx.asm
; link xxx.obj
; debug xxx.exe
; ****************************************
; debug
; t (段:偏移) (条数) 执行几条指令
; p 同 t 但是MASM5以上版本
; r 显示所有寄存器和下一条指令
; r [寄存器名] 修改指定寄存器内容
; u [地址] (终止地址) machine -> assembly
; g (地址) (断点地址) 执行
; d (地址) (终止地址) 查看内存内容
; q quit
