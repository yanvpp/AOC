start:
    
;    ADD  R16, R17
;    SUBI R16, -22
;    MOV R18, R16
    
    LDI R18, 22
    ADD R18, R16
    ADD R18, R17    
    
    RJMP start