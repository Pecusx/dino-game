SCR_HEIGHT = 8
WORLD_LENGTH = 64
DIFF_LEVELS = 16

;  No internet
;---------------------------------------------------
    OPT r+

;---------------------------------------------------
; Zpage variables
    .zpvar temp_w   .word = $80
    .zpvar temp_b   .byte
    .zpvar DinoWalkPhase    .byte
    .zpvar DinoState    .byte   ; 0/1 - walk, 2/3 - crouch, 4... - jump 
    .zpvar JumpPhase    .byte
    .zpvar Hit  .byte
;---------------------------------------------------
    icl 'lib/ATARISYS.ASM'
    icl 'lib/MACRO.ASM'
;---------------------------------------------------
    ; dark screean and BASIC off
    ORG $2000
    mva #0 dmactls             ; dark screen
    mva #$ff portb
    ; and wait one frame :)
    waitRTC                   ; or waitRTC ?
    mva #$ff portb        ; BASIC off
    rts
    ini $2000
;---------------------------------------------------

    org $2000
;---------------------------------------------------
; 4 charsets for fine scroll
font1
    ins 'artwork/dino1.fnt'  ; 1 charset
font2 = font1+$400
    ins 'artwork/dino2.fnt'  ; 2 charset
font3 = font2+$400
    ins 'artwork/dino3.fnt'  ; 3 charset
font4 = font3+$400
    ins 'artwork/dino4.fnt'  ; 4 charset
    org font4+$400
; screen data
; SCR_HEIGHT lines 256bytes each
screen
    .ds $100*SCR_HEIGHT
; display list
GameDL
    :13 .byte SKIP8   ; empty lines

    .byte MODE2+LMS   ; gr.8+LMS
    .word status_line

    .byte SKIP8 ; empty lines

    .rept SCR_HEIGHT, #
      .byte MODE2+LMS+SCH   ; gr.0+LMS+HSCRL
line:1_addr
        .word screen+$100*#
    .endr
    .byte JVB   
    .word GameDL
status_line
    dta d"  l-hi 00000  r-hi 00000         00000  "
score=status_line+33
;---------------------------------------------------
; World table without dino
WorldTable
    :WORLD_LENGTH .byte 0 ; ground
;---------------------------------------------------
FirstSTART
    jsr GenerateCharsets
    jsr SetGameScreen
    jsr FadeColors
NewGame    
    jsr SetStart        
EndLoop
    ;lda #$32
    ;sta COLBAK
    jsr WorldToScreen
    jsr ShowDino
    lda Hit
    bne EndGame
    ;lda #$5f
    ;sta COLBAK
    jsr CheckJoy
    mva #>font2 chbas
    waitRTC                   ; or waitRTC ?
    mva #3 hscrol
    mva #>font3 chbas
    waitRTC                   ; or waitRTC ?
    mva #2 hscrol
    jsr WorldShift  ; better place (flickering)
    mva #>font4 chbas
    waitRTC                   ; or waitRTC ?
    mva #1 hscrol
    jsr Animate
    mva #>font1 chbas
    waitRTC                   ; or waitRTC ?
    mva #4 hscrol
    jmp EndLoop
EndGame
    key
    jmp NewGame
    rts

;-----------------------------------------------
; Generation of character sets 2,3 and 4 of 1
; By copying and horizontal shift dino
;-----------------------------------------------
.proc GenerateCharsets
    ; copy charset 1 to 2,3 and 4 (but not dino chars)
    ldy #0
CopyLoop
    lda font1,y
    sta font2,y
    sta font3,y
    sta font4,y
    lda font1+$200,y
    sta font2+$200,y
    sta font3+$200,y
    sta font4+$200,y
    lda font1+$300,y
    sta font2+$300,y
    sta font3+$300,y
    sta font4+$300,y
    iny
    bne CopyLoop
    
    rts
.endp
;-----------------------------------------------
.proc ClearWorld
    ldy #WORLD_LENGTH-1 ; world size
    lda #0  ; ground
@   sta WorldTable,y
    dey
    bpl @-
    rts
.endp
.proc ClearScreen
    ldy #44 ; visible screen len
    lda #0
ClearLoop
    sta screen+$700,y
    sta screen+$600,y
    sta screen+$500,y
    sta screen+$400,y
    sta screen+$300,y
    sta screen+$200,y
    sta screen+$100,y
    dey
    bne ClearLoop
    rts
.endp
;-----------------------------------------------
.proc WorldToScreen
    jsr ClearScreen
    ldx #0  ; start position
    stx temp_b
ToScreenLoop
    lda WorldTable,x
    bmi NothingToDraw
    tay
    jsr ShowObject
NothingToDraw
    inc temp_b
    ldx temp_b
    cpx #WORLD_LENGTH
    bne ToScreenLoop
    rts
.endp
;-----------------------------------------------
.proc WorldShift
    jsr ScoreUp
    ldy #0
Shift
    lda WorldTable+1,y
    sta WorldTable,y
    iny
    cpy #WORLD_LENGTH-1
    bne Shift
    lda #0  ;ground
    sta WorldTable,y
    ; now we can insert random object to world end
    
    ; check if there is enough of the gap between obstacles
    
    ; get the gap for the given difficulty level
    ldx diff_level
    lda #WORLD_LENGTH
    sec
    sbc diff_object_gap,x
    tax 

    ; is there a gap?
@
    lda WorldTable,x
    bne noInsert
    inx
    cpx #WORLD_LENGTH
    bne @-
    ;all zeroes
insertObject
    lda RANDOM
    and #%00000001  ; insert 50/50
    beq noInsert
    randomize 8 13  ; cactuses and hole
    sta WorldTable+WORLD_LENGTH-2
    ora #$80
    sta WorldTable+WORLD_LENGTH-1
    inc diff_level
    
    
    
noInsert    
    rts
.endp
;-----------------------------------------------
.proc ScoreUp
    inc score+4
    lda score+4
    cmp #$1a    ; 9+1 character code
    bne ScoreReady
    lda #$10    ; 0 character code
    sta score+4
    inc score+3
    lda score+3
    cmp #$1a    ; 9+1 character code
    bne ScoreReady
    lda #$10    ; 0 character code
    sta score+3
    inc score+2
    lda score+2
    cmp #$1a    ; 9+1 character code
    bne ScoreReady
    lda #$10    ; 0 character code
    sta score+2
    inc score+1
    lda score+1
    cmp #$1a    ; 9+1 character code
    bne ScoreReady
    lda #$10    ; 0 character code
    sta score+1
    inc score
ScoreReady 
    rts
.endp
;-----------------------------------------------
.proc Animate
    ldy #WORLD_LENGTH
@   lda WorldTable,y
    tax
    and #%01111111
    beq NoBird
    cmp #8 ; first cactus
    bcs NoBird
    ; then animate bird
    txa
    eor #%0000001
    sta WorldTable,y
NoBird
    dey
    bpl @-
    ; animate Dino
    lda DinoWalkPhase
    eor #%00000001
    sta DinoWalkPhase
    ; jump
    lda DinoState
    cmp #4  ; jump state
    bne NoJump
    lda JumpPhase
    cmp #JumpLen  ; max jump phase
    beq EndJump
    inc JumpPhase
    rts
EndJump
    lda #0
    sta JumpPhase
    sta DinoState
NoJump
    rts
.endp
;-----------------------------------------------
; Show Object on screen
; X - y position
; Y - shape nr
;-----------------------------------------------
.proc ShowObject
    lda ShapesTableL,y
    sta temp_w
    lda ShapesTableH,y
    sta temp_w+1
    ldy #0
ObjectLoop
    lda (temp_w),y
    bmi @+
    sta screen+$400,x
@   adw temp_w #2
    lda (temp_w),y
    bmi @+
    sta screen+$500,x
@   adw temp_w #2
    lda (temp_w),y
    bmi @+
    sta screen+$600,x
@   adw temp_w #2
    lda (temp_w),y
    bmi @+
    sta screen+$700,x
@   sbw temp_w #6
    inx
    iny
    cpy #2  ; object width
    bne ObjectLoop
    rts
.endp
;-----------------------------------------------
; Show Dino on screen (test)
;-----------------------------------------------
.proc ShowDino
    ldx #5 ; position
    lda DinoState
    ora DinoWalkPhase  ; shape
    tay
    lda DinoShapesTableL,y
    sta temp_w
    lda DinoShapesTableH,y
    sta temp_w+1
    cpy #4  ; jump
    beq Jump
    cpy #5  ; jump
    beq Jump
    ldy #0
DinoLoop
    lda (temp_w),y
    bmi @+
    lda screen+$400,x   ; check obstacle
    beq NotHit0a
    lda #$5b    ; make hit mark
    sta Hit
    bne Hit0a
NotHit0a
    lda (temp_w),y
Hit0a
    sta screen+$400,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    lda screen+$500,x
    beq NotHit0b
    lda #$5b    ; hit mark
    sta Hit
    bne Hit0b
NotHit0b
    lda (temp_w),y
Hit0b
    sta screen+$500,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    lda screen+$600,x
    beq NotHit0c
    lda #$5b    ; hit mark
    sta Hit
    bne Hit0c
NotHit0c
    lda (temp_w),y
Hit0c
    sta screen+$600,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    sta screen+$700,x
@   sbw temp_w #15
    inx
    iny
    cpy #5  ; dino width
    bne DinoLoop
    rts
Jump
    ldy JumpPhase
    lda DinoJumpTr,y
    cmp #2
    jeq jPhase2
    cmp #3
    jeq jPhase3
    cmp #4
    jeq jPhase4
jPhase1
    ldy #0
DinoLoop1
    lda (temp_w),y
    bmi @+
    sta screen+$300,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    lda screen+$400,x   ; check obstacle
    beq NotHit1a
    lda #$5b    ; make hit mark
    sta Hit
    bne Hit1a
NotHit1a
    lda (temp_w),y
Hit1a
    sta screen+$400,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    lda screen+$500,x   ; check obstacle
    beq NotHit1b
    lda #$5b    ; make hit mark
    sta Hit
    bne Hit1b
NotHit1b
    lda (temp_w),y
Hit1b
    sta screen+$500,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    lda screen+$600,x   ; check obstacle
    beq NotHit1c
    lda #$5b    ; make hit mark
    sta Hit
    bne Hit1c
NotHit1c
    lda (temp_w),y
Hit1c
    sta screen+$600,x
@   sbw temp_w #15
    inx
    iny
    cpy #5  ; dino width
    bne DinoLoop1
    rts
jPhase2
    ldy #0
DinoLoop2
    lda (temp_w),y
    bmi @+
    sta screen+$200,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    sta screen+$300,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    lda screen+$400,x   ; check obstacle
    beq NotHit2a
    lda #$5b    ; make hit mark
    sta Hit
    bne Hit2a
NotHit2a
    lda (temp_w),y
Hit2a
    sta screen+$400,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    lda screen+$500,x   ; check obstacle
    beq NotHit2b
    lda #$5b    ; make hit mark
    sta Hit
    bne Hit2b
NotHit2b
    lda (temp_w),y
Hit2b
    sta screen+$500,x
@   sbw temp_w #15
    inx
    iny
    cpy #5  ; dino width
    bne DinoLoop2
    rts
jPhase3
    ldy #0
DinoLoop3
    lda (temp_w),y
    bmi @+
    sta screen+$100,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    sta screen+$200,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    sta screen+$300,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    lda screen+$400,x   ; check obstacle
    beq NotHit3a
    lda #$5b    ; make hit mark
    sta Hit
    bne Hit3a
NotHit3a
    lda (temp_w),y
Hit3a
    sta screen+$400,x
@   sbw temp_w #15
    inx
    iny
    cpy #5  ; dino width
    bne DinoLoop3
    rts
jPhase4
    ldy #0
DinoLoop4
    lda (temp_w),y
    bmi @+
    sta screen,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    sta screen+$100,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    sta screen+$200,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    sta screen+$300,x
@   sbw temp_w #15
    inx
    iny
    cpy #5  ; dino width
    bne DinoLoop4
    rts
.endp
;-----------------------------------------------
.proc CheckJoy
    lda DinoState
    cmp #4  ; jump state
    beq NoChange
    lda STICK0
    and #%00000010  ; down
    beq Down
    lda STICK0
    and #%00000001  ; up
    beq Up
    ; check keyboard
    lda SKSTAT
    cmp #$f7    ; SHIFT
    beq Down
    cmp #$ff
    beq Walk
    lda kbcode
    cmp #@kbcode._space
    beq Up
Walk
    lda #0
    sta DinoState
NoChange
    rts
Up  lda #4
    sta DinoState
    lda #0
    sta JumpPhase
    rts
Down
    lda #2
    sta DinoState
    rts
.endp
;-----------------------------------------------
.proc SetStart
    jsr ClearWorld
    lda #0
    sta DinoWalkPhase
    sta DinoState
    sta diff_level
    sta Hit
    ; clear score
    lda #$10
    sta score
    sta score+1
    sta score+2
    sta score+3
    sta score+4
    rts
.endp
;-----------------------------------------------
.proc FadeColors
    ldy #0
    sty COLOR1
FadeColor
    sty COLOR2
    sty COLOR4
    waitRTC
    iny
    cpy #$10
    bne FadeColor
    lda #$0f
    sta COLOR2
    sta COLOR4
    rts
.endp
;-----------------------------------------------
.proc SetGameScreen
    mwa #GameDL dlptrs
    lda #%00111110  ; normal screen width, DL on, P/M on
    sta dmactls
    mva #>font1 chbas
    rts
.endp
;--------------------------------------------------
    icl 'artwork/shapes.asm'
;--------------------------------------------------

    run FirstSTART
