;   @com.wudsn.ide.asm.mainsourcefile=dino.asm

    .IF *>0 ;this is a trick that prevents compiling this file alone

; dno run
dino_run_0  ; anly '0' jumps
    .by $ff, $23, $27, $2b, $ff ; '.   .'
    .by $20, $24, $28, $2c, $ff ; ' ## .'
    .by $21, $25, $29, $ff, $ff ; '## ..'
    .by $22, $26, $2a, $ff, $ff ; '## ..'
dino_run_1
    .by $ff, $23, $27, $2b, $ff ; '.   .'
    .by $20, $24, $28, $2c, $ff ; ' ## .'
    .by $21, $25, $29, $ff, $ff ; '## ..'
    .by $2d, $2e, $2f, $ff, $ff ; '## ..'
dino_run_2
    .by $ff, $23, $27, $2b, $ff ; '.   .'
    .by $20, $24, $28, $2c, $ff ; ' ## .'
    .by $21, $25, $29, $ff, $ff ; '## ..'
    .by $30, $31, $32, $ff, $ff ; '## ..'
dino_crouch_1
    .by $ff, $ff, $ff, $ff, $ff ; '.....'
    .by $ff, $ff, $ff, $ff, $ff ; '.....'
    .by $33, $34, $35, $36, $37 ; '#### '
    .by $38, $39, $3a, $3b, $3c ; '#### '
dino_crouch_2
    .by $ff, $ff, $ff, $ff, $ff ; '.....'
    .by $ff, $ff, $ff, $ff, $ff ; '.....'
    .by $33, $34, $35, $36, $37 ; '#### '
    .by $3d, $3e, $3f, $3b, $3c ; '#### '
DinoShapesTableL
    .by <dino_run_1
    .by <dino_run_2
    .by <dino_crouch_1
    .by <dino_crouch_2
    .by <dino_run_0 ; jump
    .by <dino_run_0 ; jump
DinoShapesTableH
    .by >dino_run_1
    .by >dino_run_2
    .by >dino_crouch_1
    .by >dino_crouch_2
    .by >dino_run_0 ; jump
    .by >dino_run_0 ; jump
; other objects
ground_0
    .by $ff, $ff    ; '..'
    .by $ff, $ff    ; '..'
    .by $ff, $ff    ; '..'
    .by $52, $52    ; '##'
bird_0
    .by $ff, $ff    ; '..'
    .by $ff, $ff    ; '..'
    .by $40, $41    ; '##'
    .by $52, $52    ; '##'
bird_1
    .by $ff, $ff    ; '..'
    .by $40, $41    ; '##'
    .by $ff, $ff    ; '..'
    .by $52, $52    ; '##'
bird_2
    .by $40, $41    ; '##'
    .by $ff, $ff    ; '..'
    .by $ff, $ff    ; ''.'
    .by $52, $52    ; '##'
bird_0a
    .by $ff, $ff    ; '..'
    .by $ff, $ff    ; '..'
    .by $42, $43    ; '##'
    .by $52, $52    ; '##'
bird_1a
    .by $ff, $ff    ; '..'
    .by $42, $43    ; '##'
    .by $ff, $ff    ; '..'
    .by $52, $52    ; '##'
bird_2a
    .by $42, $43    ; '##'
    .by $ff, $ff    ; '..'
    .by $ff, $ff    ; ''.'
    .by $52, $52    ; '##'
cactus_0
    .by $ff, $ff    ; '..'
    .by $ff, $ff    ; '..'
    .by $46, $47    ; '##'
    .by $44, $45    ; '##'
cactus_1
    .by $ff, $ff    ; '..'
    .by $ff, $ff    ; '..'
    .by $4a, $4b    ; '##'
    .by $48, $49    ; '##'
cactus_2
    .by $ff, $ff    ; '..'
    .by $50, $51    ; '##'
    .by $4e, $4f    ; '##'
    .by $4c, $4d    ; '##'
cactus_3
    .by $ff, $ff    ; '..'
    .by $57, $ff    ; '#.'
    .by $56, $ff    ; '#.'
    .by $55, $52    ; '##'
cactus_4
    .by $ff, $ff    ; '..'
    .by $ff, $ff    ; '..'
    .by $59, $ff    ; '#.'
    .by $58, $52    ; '##'
ground_1
    .by $ff, $ff    ; '..'
    .by $ff, $ff    ; '..'
    .by $ff, $ff    ; '..'
    .by $53, $54    ; '##'
ground_2
    .by $ff, $ff    ; '..'
    .by $ff, $ff    ; '..'
    .by $ff, $ff    ; '..'
    .by $5a, $52    ; '##'

ShapesTableL
    .by <ground_0
    .by <ground_0
    .by <bird_0
    .by <bird_0a
    .by <bird_1
    .by <bird_1a
    .by <bird_2
    .by <bird_2a
    .by <cactus_0
    .by <cactus_1
    .by <cactus_2
    .by <cactus_3
    .by <cactus_4
    .by <ground_1
    .by <ground_2
ShapesTableH
    .by >ground_0
    .by >ground_0
    .by >bird_0
    .by >bird_0a
    .by >bird_1
    .by >bird_1a
    .by >bird_2
    .by >bird_2a
    .by >cactus_0
    .by >cactus_1
    .by >cactus_2
    .by >cactus_3
    .by >cactus_4
    .by >ground_1
    .by >ground_2
diff_object_gap ; min distance between obstacles by difficulty level
    :DIFF_LEVELS .by 20-#
;----------vars----------
diff_level  .ds 1
DinoJumpTr  .by 1,2,3,4,4,3,2,1
JumpLen = 8
.endif  ; .IF *>0
