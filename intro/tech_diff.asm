; tech diff https://www.youtube.com/live/xXDjtDJf69E?si=Sg9HLaZ1krfz-m12&t=1578
;---------------------------------------------------
    OPT r+

;---------------------------------------------------
; Zpage variables
    .zpvar temp_w   .word = $80
    .zpvar temp_b   .byte
;---------------------------------------------------
    icl '../lib/ATARISYS.ASM'
    icl '../lib/MACRO.ASM'
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
screen
    ins 'difficulties.bmp',+146
DL
    :13 .by SKIP8
    .by MODEF+LMS
    .wo screen
    :25 .by MODEF
    .by JVB
    .wo DL
    
start
    mwa #DL dlptrs
    lda #%00111110  ; normal screen width, DL on, P/M on
    sta dmactls
    mva #0 COLOR2
    sta COLBAK
    mva #15 COLOR1
    halt

    ini start
    