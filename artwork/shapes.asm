;   @com.wudsn.ide.asm.mainsourcefile=scorch.asm

    .IF *>0 ;this is a trick that prevents compiling this file alone

; dno run
dino_run_0  ; anly '0' jumps
    .by $ff, $23, $27, $2b, $ff  ; '.   '
    .by $20, $24, $28, $2c, $ff  ; ' ## '
    .by $21, $25, $29, $ff, $ff  ; '## .'
    .by $22, $26, $2a, $ff, $ff  ; '## .'
dino_run_1
    .by $ff, $23, $27, $2b, $ff  ; '.   '
    .by $20, $24, $28, $2c, $ff  ; ' ## '
    .by $21, $25, $29, $ff, $ff  ; '## .'
    .by $2d, $2e, $2f, $ff, $ff  ; '## .'
dino_run_2
    .by $ff, $23, $27, $2b, $ff  ; '.   '
    .by $20, $24, $28, $2c, $ff  ; ' ## '
    .by $21, $25, $29, $ff, $ff  ; '## .'
    .by $30, $31, $32, $ff, $ff  ; '## .'
dino_crouch_1
    .by $ff, $ff, $ff, $ff, $ff
    .by $ff, $ff, $ff, $ff, $ff
    .by $33, $34, $35, $36, $37  ; '#### '
    .by $38, $39, $3a, $3b, $3c  ; '#### '
dino_crouch_2
    .by $ff, $ff, $ff, $ff, $ff
    .by $ff, $ff, $ff, $ff, $ff
    .by $33, $34, $35, $36, $37  ; '#### '
    .by $3d, $3e, $3f, $3b, $3c  ; '#### '
ShapesTableL
    .by <dino_run_0
    .by <dino_run_1
    .by <dino_run_2
    .by <dino_crouch_1
    .by <dino_crouch_2
ShapesTableH
    .by >dino_run_0
    .by >dino_run_1
    .by >dino_run_2
    .by >dino_crouch_1
    .by >dino_crouch_2

.endif  ; .IF *>0
