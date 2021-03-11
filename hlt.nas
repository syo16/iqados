[BITS 32]
    MOV AL,'A'
    CALL 2*8:0x1444
fin:
    HLT
    JMP fin
