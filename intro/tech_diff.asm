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
    POKEY_INIT
    pause 3
    lda #0
    sta $d40e   ; wylaczamy NMI 
    sei         ; oraz IRQ
    
    
    ;-----playa-da-sampla-----
    ldx #0

please_wait_loop    
    lda samples_l,x
    sta sample_load
    lda samples_h,x
    sta sample_load+1
    
    lda samples_end_l,x
    sta temp_w
    lda samples_end_h,x
    sta temp_w+1
    
@    
    lda sample_load: $ffff
    tay
    sec
    :4 ror
    sta AUDC1
    sta AUDC2
    sta AUDC3
    ;sta AUDC4
    :3 sta wsync
    tya
    and #$0F
    ora #$10
    sta AUDC1
    sta AUDC2
    sta AUDC3
    ;sta AUDC4


    inw sample_load
    sta wsync
    cpw sample_load temp_w
    sta wsync
    beq @+
    sta wsync
    jmp @-    
@
    inx
    cpx #13
    sne:ldx #0
    jmp please_wait_loop
 
 
sample1
    ins 'wait1.wav.bin'
sample_end1
sample2
    ins 'wait2.wav.bin'
sample_end2
sample3
    ins 'wait3.wav.bin'
sample_end3
sample4
    ins 'wait4.wav.bin'
sample_end4
sample5
    ins 'wait5.wav.bin'
sample_end5
sample6
    ins 'wait6.wav.bin'
sample_end6

samples_l
    .by <sample1
    .by <sample2
    .by <sample3
    .by <sample2
    .by <sample4
    .by <sample2
    .by <sample5
    .by <sample2
    .by <sample3
    .by <sample2
    .by <sample4
    .by <sample2
    .by <sample6
samples_h
    .by >sample1
    .by >sample2
    .by >sample3
    .by >sample2
    .by >sample4
    .by >sample2
    .by >sample5
    .by >sample2
    .by >sample3
    .by >sample2
    .by >sample4
    .by >sample2
    .by >sample6
samples_end_l
    .by <sample_end1
    .by <sample_end2
    .by <sample_end3
    .by <sample_end2
    .by <sample_end4
    .by <sample_end2
    .by <sample_end5
    .by <sample_end2
    .by <sample_end3
    .by <sample_end2
    .by <sample_end4
    .by <sample_end2
    .by <sample_end6
samples_end_h
    .by >sample_end1
    .by >sample_end2
    .by >sample_end3
    .by >sample_end2
    .by >sample_end4
    .by >sample_end2
    .by >sample_end5
    .by >sample_end2
    .by >sample_end3
    .by >sample_end2
    .by >sample_end4
    .by >sample_end2
    .by >sample_end6

    ini start
