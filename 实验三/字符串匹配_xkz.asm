DATA SEGMENT
    KLENMAX     DB 8
    KLEN        DB ?
    KSTR        DB 8 DUP(?)

    SLENMAX     DB 32
    SLEN        DB ?
    SSTR        DB 32 DUP(?)

    KPROMPT     DB "Enter a keyword: $"
    SPROMPT     DB "Enter a sentence: $"

    MPROMPTPRE  DB "Match at position: $"
    MPROMPTPOST DB "H of the sentence$"

    NMPROMPTPRE DB "No match found$"
DATA ENDS


CODE SEGMENT
               ASSUME CS:CODE, DS:DATA, ES:DATA

PUTC PROC
               PUSH   BP
               MOV    BP,SP
               PUSH   DX
               PUSH   AX

               MOV    DL,[BP-2]
               MOV    AH,02H
               INT    21H

               POP    AX
               POP    DX
               POP    BP
               RET
PUTC ENDP

PUTS PROC
               PUSH   BP
               MOV    BP,SP
               PUSH   DX
               PUSH   AX

               MOV    DX,[BP-2]
               MOV    AH,09H
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
               MOV    AH,0AH
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

PUTDB PROC
               PUSH   BP
               MOV    BP,SP

               PUSH   DX
               PUSH   CX
               PUSH   BX
               PUSH   AX

               MOV    BX,[BP-2]

               MOV    CH,04H
    SWITCHLAST:
               MOV    CL,4H
               ROL    BX,CL
               MOV    AL,BL
               AND    AL,0FH
               ADD    AL,30H
               CMP    AL,3AH
               JL     LAST
               ADD    AL,07H
    LAST:      
               MOV    DX,00H
               MOV    DL,AL
               PUSH   DX
               CALL   PUTC
               ADD    SP,2
               DEC    CH
               JNZ    SWITCHLAST
    
               POP    AX
               POP    BX
               POP    CX
               POP    DX
               POP    BP
               RET
PUTDB ENDP

MAIN PROC FAR
    START:     
               MOV    AX,DATA                      ;初始化数据段寄存器
               MOV    DS,AX
               MOV    ES,AX
            
            

               LEA    DX,KPROMPT                   ;输出"Enter a keyword: "
               PUSH   DX
               CALL   PUTS
               ADD    SP,2

               LEA    DX,KLENMAX                   ;获取关键词
               PUSH   DX
               CALL   GETS
               ADD    SP,2


               CALL   NLINE                        ;换行

               LEA    DX,SPROMPT                   ; 输出"Enter a sentence: "
               PUSH   DX
               CALL   PUTS
               ADD    SP,2

               LEA    DX,SLENMAX                   ;获取待匹配的句子
               PUSH   DX
               CALL   GETS
               ADD    SP,2

               CALL   NLINE                        ;输出换行

               LEA    SI,KSTR                      ; 设置SI寄存器指向关键字字符串

               LEA    BX,SSTR                      ; 设置BX寄存器指向句子字符串
               LEA    DI,SSTR                      ; 设置DI寄存器指向句子字符串
               MOV    DL,00H
               CLD

    TRY_MATCH: 
               MOV    CL,KLEN                      ; 设置CL为关键字的实际长度
               REPZ   CMPSB                        ; 比较SI和DI指向的字符串，长度为CL。会改变DI和SI的值
               JZ     MATCH                        ; 如果匹配成功，跳转到MATCH标签

               MOV    AL,SLEN                      ; 设置AL为句子的实际长度--最大匹配次数
               CMP    AL,KLEN
               JL     NOMATCH                      ; 若句子长度小于关键词长度，跳转到NOMATCH标签

               LEA    SI,KSTR                      ;将SI重新指向关键字字符串
               INC    BX                           ;句子字符串偏移量+1
               MOV    DI,BX
    ;    INC DI

               INC    DL                           ;记录匹配次数
               CMP    DL, AL                       ;若不超过最大匹配次数
               JL     TRY_MATCH

    NOMATCH:   
               LEA    DX,NMPROMPTPRE
               PUSH   DX
               CALL   PUTS
               ADD    SP,2
               JMP    EXIT

    MATCH:     
               LEA    DX,MPROMPTPRE
               PUSH   DX
               CALL   PUTS
               ADD    SP,2

               MOV    AX,BX
               LEA    BX,SSTR
               SUB    AX,BX
               MOV    BX,0001H
               ADD    AX,BX
               AND    AX, 00FFH
               
               MOV    DX,   AX
               PUSH   DX
               CALL   PUTDB
               ADD    SP,2

             
               LEA    DX,MPROMPTPOST
               PUSH   DX
               CALL   PUTS
               ADD    SP,2

    EXIT:      
               MOV    AH,4CH
               INT    21H

MAIN ENDP

CODE ENDS
    END MAIN
