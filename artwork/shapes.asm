;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

    .IF *>0 ;this is a trick that prevents compiling this file alone

; dno run
dino_run_0  ; anly '0' jumps
    .by $ff, $23, $27, $2b  ; '.   '
    .by $20, $24, $28, $2c  ; ' ## '
    .by $21, $25, $29, $ff  ; '## .'
    .by $22, $26, $2a, $ff  ; '## .'
dino_run_1
    .by $ff, $23, $27, $2b  ; '.   '
    .by $20, $24, $28, $2c  ; ' ## '
    .by $21, $25, $29, $ff  ; '## .'
    .by $2d, $2e, $2f, $ff  ; '## .'
dino_run_2
    .by $ff, $23, $27, $2b  ; '.   '
    .by $20, $24, $28, $2c  ; ' ## '
    .by $21, $25, $29, $ff  ; '## .'
    .by $30, $31, $32, $ff  ; '## .'
dino_crouch_1
    .by $33, $34, $35, $36, $37  ; '#### '
    .by $38, $39, $3a, $3b, $3c  ; '#### '
dino_crouch_2
    .by $33, $34, $35, $36, $37  ; '#### '
    .by $3d, $3e, $3f, $3b, $3c  ; '#### '


.endif  ; .IF *>0
