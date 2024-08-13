SCR_HEIGHT = 8
WORLD_LENGTH = 64
DIFF_LEVELS = 20
.IFNDEF ALONE
    .def ALONE = 1 ; standalone version
.ENDIF
.IFNDEF TARGET
    .def TARGET = 800 ; 5200
.ENDIF
;---------------------------------------------------
;  No internet
;---------------------------------------------------
    OPT r+

swap_table=$0600    ; table for swap bytes in left characters :)

;---------------------------------------------------
; Zpage variables
    .zpvar temp_w           .word = $80
    .zpvar temp_b           .byte
    .zpvar temp_b2          .byte
    .zpvar DinoWalkPhase    .byte
    .zpvar DinoState        .byte   ; 0/1 - walk, 2/3 - crouch, 4... - jump 
    .zpvar JumpPhase        .byte
    .zpvar Hit              .byte
    .zpvar Level            .byte
;---------------------------------------------------
    icl 'lib/ATARISYS.ASM'
    icl 'lib/MACRO.ASM'
;---------------------------------------------------
    .IF ALONE =1
        ; dark screean and BASIC off
        ORG $2000
        mva #0 dmactls             ; dark screen
        mva #$ff portb
        ; and wait one frame :)
        waitRTC                   ; or waitRTC ?
        mva #$ff portb        ; BASIC off
        rts
        ini $2000
    .ENDIF
;---------------------------------------------------

    org $2000
PMgraph
    org PMGraph+$800    ; P/M graphics for clouds
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
; display list
GameDL
    :8 .byte SKIP8   ; empty lines

    .byte MODE2+LMS   ; gr.8+LMS
status_line_addr
    .word status_line_r    
    :4 .byte SKIP8
    .byte MODE2

    .byte SKIP8,SKIP8 ; empty lines

    .rept SCR_HEIGHT, #
      .byte MODE2+LMS+SCH   ; gr.0+LMS+HSCRL
line:1_addr
        .word screen+$100*#
    .endr
    .byte JVB   
    .word GameDL
status_line_r
    dta d"             "
    .byte $5d   ; "N" letter
    dta               d"o internet!               "
    dta d"  "
    .byte $5e   ; "L" letter
    dta    d"-"
    .byte $7e,$7f   ; "HI" letters
    dta       d" 00000  "
    .byte $5f   ; "R" letter
    dta                d"-"
    .byte $7e,$7f   ; "HI" letters
    dta                  d" 00000         00000  "
status_line_l
    dta d"             !tenretni o"
    .byte $5d   ; "N" letter
    dta                          d"               "
    dta d"  00000         00000 "
    .byte $7f,$7e   ; "IH" letters
    dta                         d"-"
    .byte $5f   ; "R" letter
    dta                           d"  00000 "
    .byte $7f,$7e   ; "IH" letters
    dta                                     d"-"
    .byte $5e   ; "L" letter
    dta                                       d"  "
score=status_line_r+33+40
rhiscore=status_line_r+19+40
lhiscore=status_line_r+7+40
scorel=status_line_l+2+40
rhiscorel=status_line_l+16+40
lhiscorel=status_line_l+28+40
game_over_string
    .byte $60   ; "G" letter
    dta d" a m e  "
    .byte $7b   ; "O" letter
    dta d" v e r"
repeat_symbol
    .byte $1c, $1e
    .byte $7c, $7d
;---------------------------------------------------
; World table without dino
WorldTable
    :WORLD_LENGTH+1 .byte 0 ; ground
;---------------------------------------------------
FirstSTART
    jsr ClearScreen
    jsr GenerateCharsets
    jsr GenerateClouds
    jsr FadeColorsIN
    ;AnyKey
    jsr SetGameScreen
NewGame    
    jsr SetStatusToR
    jsr SetStart        
    jsr GameR
    jsr GameOverR
    AnyKey
    jsr HiScoreR
    jsr SetStatusToL
    jsr SetStart        
    jsr GameL
    jsr GameOverL
    AnyKey
    jsr HiScoreL   
    jmp NewGame
    rts

;-----------------------------------------------
.proc GameR
EndLoopR
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
    jsr CloudsR
    mva #>font4 chbas
    waitRTC                   ; or waitRTC ?
    mva #1 hscrol
    jsr Animate
    mva #>font1 chbas
    waitRTC                   ; or waitRTC ?
    mva #4 hscrol
    jmp EndLoopR
EndGame
    rts
.endp
;-----------------------------------------------
.proc GameL
EndLoopL
    ;lda #$32
    ;sta COLBAK
    jsr WorldToScreenL
    jsr ShowDinoL
    lda Hit
    bne EndGameL
    ;lda #$5f
    ;sta COLBAK
    jsr CheckJoy
    mva #>font2l chbas
    waitRTC                   ; or waitRTC ?
    mva #2 hscrol
    mva #>font3l chbas
    waitRTC                   ; or waitRTC ?
    mva #3 hscrol
    jsr WorldShift  ; better place (flickering)
    jsr CloudsL
    mva #>font4l chbas
    waitRTC                   ; or waitRTC ?
    mva #4 hscrol
    jsr Animate
    mva #>font1l chbas
    waitRTC                   ; or waitRTC ?
    mva #1 hscrol
    jmp EndLoopL
EndGameL
    rts
.endp
;-----------------------------------------------
.proc GameOverR
    ; text
    ldy #15
@   lda game_over_string,y
    sta screen+$100+15,y
    dey
    bpl @-
    ; symbol
    lda repeat_symbol
    sta screen+$500+22
    lda repeat_symbol+1
    sta screen+$500+23
    lda repeat_symbol+2
    sta screen+$600+22
    lda repeat_symbol+3
    sta screen+$600+23
    rts
.endp
;-----------------------------------------------
.proc GameOverL
    ; text
    ldy #15
    ldx #0
@   lda game_over_string,y
    sta screen+$100+15,x
    inx
    dey
    bpl @-
    ; symbol
    lda repeat_symbol
    sta screen+$500+23
    lda repeat_symbol+1
    sta screen+$500+22
    lda repeat_symbol+2
    sta screen+$600+23
    lda repeat_symbol+3
    sta screen+$600+22
    rts
.endp
;-----------------------------------------------
; Generation of character sets 2,3 and 4 of 1
; By copying and horizontal shift dino
;-----------------------------------------------
.proc GenerateCharsets
    ; copy charset 1 to 2,3 and 4 (but not dino chars)
    ldy #0
CopyLoop
    ; no dino characters
    lda font1,y
    sta font2,y
    sta font3,y
    sta font4,y
    sta font1l,y
    sta font2l,y
    sta font3l,y
    sta font4l,y
    lda font1+$200,y
    sta font2+$200,y
    sta font3+$200,y
    sta font4+$200,y
    sta font1l+$200,y
    sta font2l+$200,y
    sta font3l+$200,y
    sta font4l+$200,y
    lda font1+$300,y
    sta font2+$300,y
    sta font3+$300,y
    sta font4+$300,y
    sta font1l+$300,y
    sta font2l+$300,y
    sta font3l+$300,y
    sta font4l+$300,y
    ; swap bits to make 'left' charsets
    lda font1+$100,y
    sta font1l+$100,y
    lda font2+$100,y
    sta font2l+$100,y
    lda font3+$100,y
    sta font3l+$100,y
    lda font4+$100,y
    sta font4l+$100,y  
    iny
    bne CopyLoop
    ; create table for swapping
    ldy #0
@   sty temp_b
    .REPT 8
    rol temp_b
    ror @
    .ENDR
    sta swap_table,y
    iny
    bne @-
    ; swap bits in bharacters
    ldy #0
SwapLoop
    lda font1+$100,y
    tax
    lda swap_table,x
    sta font1l+$100,y
    lda font2+$100,y
    tax
    lda swap_table,x
    sta font2l+$100,y
    lda font3+$100,y
    tax
    lda swap_table,x
    sta font3l+$100,y
    lda font4+$100,y
    tax
    lda swap_table,x
    sta font4l+$100,y
    lda font1,y
    tax
    lda swap_table,x
    sta font1l,y
    sta font2l,y
    sta font3l,y
    sta font4l,y
    lda font1+$200,y
    tax
    lda swap_table,x
    sta font1l+$200,y
    sta font2l+$200,y
    sta font3l+$200,y
    sta font4l+$200,y
    lda font1+$300,y
    tax
    lda swap_table,x
    sta font1l+$300,y
    sta font2l+$300,y
    sta font3l+$300,y
    sta font4l+$300,y
    iny
    bne SwapLoop    
    rts
.endp
;-----------------------------------------------
.proc GenerateClouds
    ; first clear PMgraphics memory
    ldy #$00
    tya
    ;hide PM
    sta CloudHpos
    sta CloudHpos+1
    sta CloudHpos+2
    sta CloudHpos+3
@   sta PMgraph+$300,y
    sta PMgraph+$400,y
    sta PMgraph+$500,y
    sta PMgraph+$600,y
    sta PMgraph+$700,y
    iny
    bne @-
    ; now make 4 clouds
    ldy #7
@   lda font1+$2e0,y    ; cloud symbol ($5c)
    sta PMgraph+$400+$78,y
    sta PMgraph+$700+$80,y
    lda font1l+$2e0,y
    sta PMgraph+$600+$78,y
    sta PMgraph+$500+$80,y
    dey
    bpl @-
    ;hide PM
    rts
.endp
;-----------------------------------------------
.proc ClearWorld
    ldy #WORLD_LENGTH ; world size
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
    sta screen+$0700,y
    sta screen+$0600,y
    sta screen+$0500,y
    sta screen+$0400,y
    sta screen+$0300,y
    sta screen+$0200,y
    sta screen+$0100,y
    sta screen+$0000,y
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
    inc:ldx temp_b
    cpx #WORLD_LENGTH
    bne ToScreenLoop
    rts
.endp
;-----------------------------------------------
.proc WorldToScreenL
    jsr ClearScreen
    ldx #0  ; start position (world)
    stx temp_b
    lda #42 ; start position (screen)
    sta temp_b2
ToScreenLoop
    lda WorldTable,x
    bmi NothingToDraw
    tay
    ldx temp_b2
    jsr ShowObjectL
NothingToDraw
    dec temp_b2
    inc:ldx temp_b
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
    cpy #WORLD_LENGTH
    bne Shift
    lda #0  ;ground
    sta WorldTable,y
    ; or sometimes mountain :)
    lda WorldTable-1,y
    bne no_mountain
    lda RANDOM
    and #%00011111  ; 32:1
    bne no_mountain
    lda #13
    sta WorldTable-1,y
    ora #$80
    sta WorldTable,y
no_mountain    
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
    lda diff_level
    cmp #2
    bcs AddBirds
NoBirds
    randomize 8 12  ; cactuses
    bne Drawn
AddBirds
    randomize 7 10  ; bigger cactuses and birds
Drawn
    cmp #7  ; if bird then select one shape from 3
    bne NoBird
    randomize 2 7
    and #%11111110
NoBird
    sta WorldTable+WORLD_LENGTH-2
    ora #$80
    sta WorldTable+WORLD_LENGTH-1
noInsert    
    rts
.endp
;-----------------------------------------------
.proc CloudsL
    inc CloudHpos
    inc CloudHpos+1
    inc CloudHpos+2
    inc CloudHpos+3
    inc CloudHpos+2
    inc CloudHpos+3
    rts
.endp
;-----------------------------------------------
.proc CloudsR
    dec CloudHpos
    dec CloudHpos+1
    dec CloudHpos+2
    dec CloudHpos+3
    dec CloudHpos+2
    dec CloudHpos+3
    rts
.endp
;-----------------------------------------------
.proc ScoreUp
    inc score+4
    lda score+4
    cmp #"9"+1  ; 9+1 character code
    bne ScoreReady
    lda #"0"    ; 0 character code
    sta score+4
    inc score+3
    lda score+3
    cmp #"9"+1  ; 9+1 character code
    bne ScoreReady
    lda #"0"    ; 0 character code
    sta score+3
    ; if score gets next 100 - level up
    inc diff_level
    lda diff_level
    cmp #DIFF_LEVELS+1
    bne @+
    dec diff_level
@   inc score+2
    lda score+2
    cmp #"9"+1  ; 9+1 character code
    bne ScoreReady
    lda #"0"    ; 0 character code
    sta score+2
    inc score+1
    lda score+1
    cmp #"9"+1  ; 9+1 character code
    bne ScoreReady
    lda #"0"    ; 0 character code
    sta score+1
    inc score
ScoreReady
    ; move to second (left) score
    ldy #4
    ldx #0
@   lda score,x
    sta scorel,y
    inx
    dey
    bpl @-
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
NoJump
    ; clouds
Clouds
    ldy #3
@   lda CloudHpos,y
    sta HPOSP0,y
    dey
    bpl @-
    rts
EndJump
    lda #0
    sta JumpPhase
    sta DinoState
    beq NoJump
.endp
;---------------------------------------------------
.proc SetStatusToL
    lda #<status_line_l
    sta status_line_addr
    lda #>status_line_l
    sta status_line_addr+1
    rts
.endp
;---------------------------------------------------
.proc SetStatusToR
    lda #<status_line_r
    sta status_line_addr
    lda #>status_line_r
    sta status_line_addr+1
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
    smi:sta screen+$400,x
    adw temp_w #2
    lda (temp_w),y
    smi:sta screen+$500,x
    adw temp_w #2
    lda (temp_w),y
    smi:sta screen+$600,x
    adw temp_w #2
    lda (temp_w),y
    smi:sta screen+$700,x
    sbw temp_w #6
    inx
    iny
    cpy #2  ; object width
    bne ObjectLoop
    rts
.endp
;-----------------------------------------------
; Show Object on screen (left)
; X - y position
; Y - shape nr
;-----------------------------------------------
.proc ShowObjectL
    lda ShapesTableL,y
    sta temp_w
    lda ShapesTableH,y
    sta temp_w+1
    ldy #1  ; object widrh-1
ObjectLoop
    lda (temp_w),y
    smi:sta screen+$400,x
    adw temp_w #2
    lda (temp_w),y
    smi:sta screen+$500,x
    adw temp_w #2
    lda (temp_w),y
    smi:sta screen+$600,x
    adw temp_w #2
    lda (temp_w),y
    smi:sta screen+$700,x
    sbw temp_w #6
    inx
    dey
    bpl ObjectLoop
    rts
.endp
;-----------------------------------------------
; Show Dino on screen and check collisions
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
    smi:sta screen+$700,x
    sbw temp_w #10
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
@   sbw temp_w #10
    inx
    iny
    cpy #5  ; dino width
    bne DinoLoop1
    rts
jPhase2
    ldy #0
DinoLoop2
    lda (temp_w),y
    smi:sta screen+$300,x
    adw temp_w #5
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
@   sbw temp_w #10
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
@   sbw temp_w #10
    inx
    iny
    cpy #5  ; dino width
    bne DinoLoop3
    rts
jPhase4
    ldy #0
DinoLoop4
    lda (temp_w),y
    smi:sta screen+$100,x
    adw temp_w #5
    lda (temp_w),y
    smi:sta screen+$200,x
    adw temp_w #5
    lda (temp_w),y
    smi:sta screen+$300,x
    sbw temp_w #10
    inx
    iny
    cpy #5  ; dino width
    bne DinoLoop4
    rts
.endp
;-----------------------------------------------
; Show Dino (left) on screen and check collisions
;-----------------------------------------------
.proc ShowDinoL
    ldx #36 ; position
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
    ldy #4  ;dino width-1
DinoLoop
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
    smi:sta screen+$700,x
    sbw temp_w #10
    inx
    dey
    bpl DinoLoop
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
    ldy #4  ; dinowidth-1
DinoLoop1
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
@   sbw temp_w #10
    inx
    dey
    bpl DinoLoop1
    rts
jPhase2
    ldy #4 ; dino width-1
DinoLoop2
    lda (temp_w),y
    smi:sta screen+$300,x
    adw temp_w #5
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
@   sbw temp_w #10
    inx
    dey
    bpl DinoLoop2
    rts
jPhase3
    ldy #4  ; dinowidth-1
DinoLoop3
    lda (temp_w),y
    smi:sta screen+$200,x
    adw temp_w #5
    lda (temp_w),y
    smi:sta screen+$300,x
    adw temp_w #5
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
@   sbw temp_w #10
    inx
    dey
    bpl DinoLoop3
    rts
jPhase4
    ldy #4  ; dino width-1
DinoLoop4
    lda (temp_w),y
    smi:sta screen+$100,x
    adw temp_w #5
    lda (temp_w),y
    smi:sta screen+$200,x
    adw temp_w #5
    lda (temp_w),y
    smi:sta screen+$300,x
    sbw temp_w #10
    inx
    dey
    bpl DinoLoop4
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
    lda #"0"
    ldx #4
@   sta score,x
    sta scorel,x
    dex
    bpl @-
    ;randomize clouds
    ldy #3
@   lda RANDOM
    sta CloudHpos,y
    dey
    bpl @-
    jsr Animate.Clouds
    rts
.endp
;-----------------------------------------------
.proc HiScoreR
    lda rhiscore
    cmp score
    bcc higher1
    bne lower
    lda rhiscore+1
    cmp score+1
    bcc higher2
    bne lower
    lda rhiscore+2
    cmp score+2
    bcc higher3
    bne lower
    lda rhiscore+3
    cmp score+3
    bcc higher4
    bne lower
    lda rhiscore+4
    cmp score+4
    bcc higher5
lower
    rts
higher1
    lda score
    sta rhiscore
higher2
    lda score+1
    sta rhiscore+1
higher3
    lda score+2
    sta rhiscore+2
higher4
    lda score+3
    sta rhiscore+3
higher5
    lda score+4
    sta rhiscore+4
    ; move score to 'left' status line
    ldy #4
    ldx #0
@   lda rhiscore,x
    sta rhiscorel,y
    inx
    dey
    bpl @-
    rts
.endp
;-----------------------------------------------
.proc HiScoreL
    lda lhiscore
    cmp score
    bcc higher1
    bne lower
    lda lhiscore+1
    cmp score+1
    bcc higher2
    bne lower
    lda lhiscore+2
    cmp score+2
    bcc higher3
    bne lower
    lda lhiscore+3
    cmp score+3
    bcc higher4
    bne lower
    lda lhiscore+4
    cmp score+4
    bcc higher5
lower
    rts
higher1
    lda score
    sta lhiscore
higher2
    lda score+1
    sta lhiscore+1
higher3
    lda score+2
    sta lhiscore+2
higher4
    lda score+3
    sta lhiscore+3
higher5
    lda score+4
    sta lhiscore+4
    ; move score to 'left' status line
    ldy #4
    ldx #0
@   lda lhiscore,x
    sta lhiscorel,y
    inx
    dey
    bpl @-
    rts
.endp
;-----------------------------------------------
.proc FadeColorsIN
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
    sta COLOR4
    sta COLOR2
    rts
.endp
;-----------------------------------------------
.proc FadeColorsOUT
    ldy #$0f
FadeColor
    sty COLOR2
    sty COLOR4
    waitRTC
    dey
    bpl FadeColor
    lda #$00
    sta COLOR2
    sta COLOR4
    rts
.endp
;-----------------------------------------------
.proc SetGameScreen
    mwa #GameDL dlptrs
    lda #@dmactl(standard|dma|players|missiles|lineX1) ; normal screen width, DL on, P/M on
    lda #%00111110
    sta dmactls
    mva #>font1 chbas
    mva #>PMgraph PMBASE
    lda #%00000010    ; P/M on
    sta GRACTL
    lda #$0c
    sta PCOLR0
    sta PCOLR1
    sta PCOLR2
    sta PCOLR3
    lda #90
    sta HPOSP0
    lda #70
    sta HPOSP1
    lda #60
    sta HPOSP2
    lda #80
    sta HPOSP3 
    rts
.endp
;-----------------------------------------------
.proc AnyKey
    ; wait for releasing keyz
@   lda CONSOL
    cmp #7
    bne @-
     ; check keyboard
@   lda SKSTAT
    cmp #$f7    ; SHIFT
    beq @-
    cmp #$ff
    bne @-
@   lda TRIG0
    beq @-

    ; test for going further
@   lda CONSOL
    cmp #7
    bne pressed
    ; check keyboard
    lda SKSTAT
    cmp #$f7    ; SHIFT
    beq pressed
    cmp #$ff
    bne pressed
    lda TRIG0
    beq pressed
    jmp @-
pressed
    ; wait for releasing keyz
@   lda CONSOL
    cmp #7
    bne @-
     ; check keyboard
@   lda SKSTAT
    cmp #$f7    ; SHIFT
    beq @-
    cmp #$ff
    bne @-
@   lda TRIG0
    beq @-
    rts   
.endp
;--------------------------------------------------
    icl 'artwork/shapes.asm'
;--------------------------------------------------
    .ALIGN $400
; and 4 charsets for left game :)
font1l
    .ds $400
font2l
    .ds $400
font3l
    .ds $400
font4l
    .ds $400
; screen data
; SCR_HEIGHT lines 256bytes each
screen
    .ds $100*SCR_HEIGHT

    run FirstSTART
