SCR_HEIGHT = 8

;  No internet
;---------------------------------------------------
    OPT r+

;---------------------------------------------------
; Zpage variables
    .zpvar temp_w     .word = $80
;---------------------------------------------------
    icl 'lib/ATARISYS.ASM'
    icl 'lib/MACRO.ASM'
;---------------------------------------------------
    ; dark screean and BASIC off
    ORG $2000
    mva #0 dmactls             ; dark screen
    mva #$ff portb
    ; and wait one frame :)
    seq:wait                   ; or waitRTC ?
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
    :5 .byte SKIP8   ; empty lines

    .rept SCR_HEIGHT, #
      .byte MODE2+LMS+SCH   ; gr.0+LMS+HSCRL
line:1_addr
        .word screen+$100*#
    .endr
    .byte JVB   
    .word GameDL

;---------------------------------------------------
FirstSTART
    ;jsr GenerateCharsets
    jsr SetGameScreen
    ldx #5 ; position
    ldy #0  ; shape
    jsr ShowDino
    ldx #10 ; position
    ldy #1  ; shape
    jsr ShowDino
    ldx #15 ; position
    ldy #2  ; shape
    jsr ShowDino
    ldx #20 ; position
    ldy #3  ; shape
    jsr ShowDino
    ldx #25 ; position
    ldy #4  ; shape
    jsr ShowDino
    mva #$50 screen+$700+32
EndLoop
    wait                   ; or waitRTC ?
    key
    mva #>font2 chbas
    waitRTC                   ; or waitRTC ?
    mva #3 hscrol
    wait                   ; or waitRTC ?
    key
    mva #>font3 chbas
    waitRTC                   ; or waitRTC ?
    mva #2 hscrol
    wait                   ; or waitRTC ?
    key
    mva #>font4 chbas
    waitRTC                   ; or waitRTC ?
    mva #1 hscrol
    wait                   ; or waitRTC ?
    key
    mva #>font1 chbas
    waitRTC                   ; or waitRTC ?
    mva #4 hscrol
    jmp EndLoop
    halt
    rts

;-----------------------------------------------
; Generation of character sets 2,3 and 4 of 1
; By copying and horizontal shift dino
;-----------------------------------------------
.proc GenerateCharsets
    ; copy charset 1 to 2,3 and 4
    ldy #0
CopyLoop
    lda font1,y
    sta font2,y
    sta font3,y
    sta font4,y
    lda font1+$100,y
    sta font2+$100,y
    sta font3+$100,y
    sta font4+$100,y
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
    ; and shifting dino shape
    
    rts
.endp

;-----------------------------------------------
; Show Dino on screen (test)
; X - y position
; Y - shape nr
;-----------------------------------------------
.proc ShowDino
    lda ShapesTableL,y
    sta temp_w
    lda ShapesTableH,y
    sta temp_w+1
    ldy #0
DinoLoop
    lda (temp_w),y
    bmi @+
    sta screen+$400,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
    sta screen+$500,x
@   adw temp_w #5
    lda (temp_w),y
    bmi @+
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
.endp
;-----------------------------------------------
; Generation of character sets 2,3 and 4 of 1
; By copying and horizontal shift dino
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
