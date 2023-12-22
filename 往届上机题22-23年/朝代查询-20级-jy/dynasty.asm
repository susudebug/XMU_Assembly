DATA SEGMENT
    MSG1  DB 'PLEASE ENTER: ', '$'
    ENTER DB 13, 10, '$'
    CDGY  DW 1, 220, 581, 618, 907, 960, 1271, 1368, 1636, 1911
    TABLE DW CD1, CD2, CD3, CD4, CD5, CD6, CD7, CD8, CD9, CD10     ;字符串偏移地址表
    CD1   DB 'HAN$'
    CD2   DB 'WEIJINNANBEICHAO$'
    CD3   DB 'SUI$'
    CD4   DB 'TANG$'
    CD5   DB 'WUDAISHIGUO$'
    CD6   DB 'SONGLIAOJINYUAN$'
    CD7   DB 'YUAN$'
    CD8   DB 'MING$'
    CD9   DB 'QING$'
    CD10  DB 'JINXIANDAI$'
DATA ENDS

CODE SEGMENT
             ASSUME CS:CODE, DS:DATA
MAIN PROC FAR
    START:   
             MOV    AX, DATA
             MOV    DS, AX

             LEA    DX, MSG1
             MOV    AH, 09
             INT    21H

             CALL   TENTOTWO

             LEA    SI, CDGY
             MOV    CX, 10
    L1:      
             CMP    [SI], BX
             JE     MATCH
             ADD    SI, 2
             LOOP   L1
             JMP    RETT

    MATCH:   
             MOV    DI, SI
             ADD    DI, 20
             MOV    DX, [DI]
             MOV    AH, 09
             INT    21H
             CALL   CTRL

    RETT:    
             RET
MAIN ENDP

CTRL PROC NEAR
             PUSH   DX
             LEA    DX, ENTER
             MOV    AH, 09
             INT    21H
             POP    DX
             RET
CTRL ENDP

    ; 10->2进制，存在BX中
TENTOTWO PROC NEAR
             MOV    BX, 0
    NEWCHAR: 
             MOV    AH, 1
             INT    21H
             SUB    AL, 30H
             JL     EXIT
             CMP    AL, 9
             JG     EXIT
             CBW
             XCHG   AX, BX
             MOV    CX, 10
             MUL    CX
             XCHG   AX, BX
             ADD    BX, AX
             JMP    NEWCHAR
    EXIT:    
             RET
TENTOTWO ENDP

CODE ENDS
END START
