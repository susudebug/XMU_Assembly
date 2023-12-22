DATAS SEGMENT
    STRING1 DB 'Enter keyword:$'
    STRING2 DB 'Enter sentence:$'
    STRING3 DB 'Match at location:$'
    STRING4 DB 'H of the sentence.',13,10,'$'   ;句号结尾，换行回车 
    STRING5 DB 'No match.',13,10,'$'
    
    FORMAT  DB  13,10,'$'   ;格式

    KEYWORD Label byte      ;存关键字
        max1    DB  10
        KLEN    DB  ?
        keywd   DB  10  dup(?)

    SENTENCE Label byte     ;存句子
        max2    DB  50
        SLEN    DB  ?
        sentc   DB  50 dup(?)

DATAS ENDS

STACKS SEGMENT

STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,ES:DATAS,SS:STACKS

main PROC far
    START:
        PUSH  DS
        XOR   AX, AX
        PUSH  AX
        MOV   AX, DATAS
        MOV   DS, AX
        MOV   ES, AX

        LEA DX, STRING1
        MOV AH, 09
        INT 21H

        LEA DX, KEYWORD  ;输入keyword
        MOV AH, 0AH      
        INT 21H

        LEA DX, FORMAT  ;格式控制
        MOV AH, 09
        INT 21H

    INPUTSENTC:
        LEA DX, STRING2
        MOV AH, 09
        INT 21H

        LEA DX, SENTENCE   ;输入sentence
        MOV AH, 0AH
        INT 21h

        LEA DX, FORMAT  ;格式控制
        MOV AH, 09
        INT 21H

        MOV AX, 0       ;清空AX
        
    LOOP_CMP:
        MOV CL, KLEN   ;cl存keyword的长度
        LEA SI, keywd  ;SI通常用来存源字符串的地址
        LEA BX, sentc  ;BX存sentence的基址
        ADD BL, AL      ;al是偏移地址
        MOV DI, BX      ;DI通常用来存目标字符串的地址

        REPE CMPSB   ;以字节为单位进行比较，直到cx=0或不相等退出
        JZ MATCH     ;CMP是两数相减进行比较，jz=0表示相等

        INC AL          ;偏移量++
        CMP AL, SLEN    ;判断是否到sentence末尾
        JAE NOT_MATCH   ;NOT MATCH
        JMP LOOP_CMP    ;继续比较

    MATCH:
        MOV BX, 0   ;为什么给bx，不直接用ax？1）
        MOV BL, AL  ;BL中存偏移量
        ADD BX, 1   ;从下标为1开始

        LEA DX, STRING3  
        MOV AH, 09  ;1) AX用处比较多
        INT 21H 

        CALL BTOH   ;二进制转十六进制子程序

        LEA DX, STRING4
        MOV AH, 09
        INT 21H

        JMP INPUTSENTC  ;

BTOH PROC FAR
        MOV CH, 4    ; 16/4, 处理四次
    ROTATE:
        MOV CL, 4    ; 一次处理四位
        ROL BX, CL   ; 循环左移四位，从最高四位开始处理(移到最低四位)
        MOV AL, BL   ; 取低8位
        AND AL, 0fh  ; 取低4位
        ADD AL, 30h  ; 转为数字字符
        CMP AL, 3AH  ; 9后面的数
        JB print
        ADD AL, 7h   ; 转为字母
    print:
        MOV DL, AL
        MOV AH, 02
        INT 21H

        DEC CH 
        JNZ ROTATE 
        RET 
BTOH endp

NOT_MATCH:
        LEA DX, STRING5
        MOV AH, 09
        INT 21H

        JMP INPUTSENTC

EXIT:
        RET
main endp
CODES ENDS
END START


