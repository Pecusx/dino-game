; tech diff https://www.youtube.com/live/xXDjtDJf69E?si=Sg9HLaZ1krfz-m12&t=1578
;---------------------------------------------------
    OPT r+

;---------------------------------------------------
; Zpage variables
    .zpvar temp_w   .word = $80
    .zpvar temp_b   .byte
    .zpvar temp_w2  .word
    .zpvar temp_w3  .word
;---------------------------------------------------
    icl '../lib/ATARISYS.ASM'
    icl '../lib/MACRO.ASM'
;---------------------------------------------------
    ; BASIC off
    ORG $2700
    mva #$ff portb
    mwa #DL_pre dlptrs
    lda #@dmactl(narrow|dma)  ; narrow screen width, DL on
    sta dmactls
    mva #0 COLOR2
    sta COLBAK
    mva #15 COLOR1
    jsr wait_for_releasing_keyz
    
leet_anim
    ; test for going further
    lda CONSOL
    cmp #7
    bne leet_end
     ; check keyboard
    lda SKSTAT
    cmp #$f7    ; SHIFT
    beq leet_end
    cmp #$ff
    bne leet_end
    lda TRIG0
    beq leet_end   
 
 
    mwa #pre_screen temp_w
    mwa #leet_screen temp_w3
    ldy #0
@
    lda (temp_w),y
    beq next_letter     ; ignore zeroes
    ;is the letter leetable?
    cmp #"a"
    bcc next_letter
    cmp #"z"+1
    bcs next_letter
    ;letter is leetable
    beq next_letter
    sec
    sbc #"a"
    tay     ;save the letter
    lda RANDOM
    and #%00000011   ; 0-3
    tax
    lda leet_speeks_l,x
    sta temp_w2
    lda leet_speeks_h,x
    sta temp_w2+1
    lda (temp_w2),y
next_letter
    ldy #0
    sta (temp_w3),y
    inw temp_w
    inw temp_w3
    cpw temp_w #pre_screen_end
    beq leet_anim
    jmp @-

leet_end
    jsr wait_for_releasing_keyz
    rts
    

.proc wait_for_releasing_keyz
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

DL_pre
    :8 .by SKIP8
    .by LMS+MODE2
    .wo leet_screen
    .by SKIP1, MODE2
    .by SKIP8
    .by SKIP1, MODE2
    .by SKIP8
    :6 .by SKIP1, MODE2
    .by JVB
    .wo DL_pre
pre_screen
    ;    01234567890123456789012345678901"
    dta "this little game was created in "
    dta " four evenings before SV2K24SE  "
    dta "sorry for technical difficulties"
    dta "code:                           "
    dta "        pecus & pirx            "
    dta "sound:                          "
    dta "        alex, jochen hippel     "
    dta "gfx:                            "
    dta "        alphabet, inc.          "
pre_screen_end
leet_speek1
    dta "abcdefghijklmnopqrstuvwxyz"
leet_speek2
    dta "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
leet_speek3
    dta "4&[)eF9-|jk_mn0p@r57uvw*y2"
leet_speek4
    dta "^b(>",$5b,$41,"gh1",$4c+$80,"k",$4b+$80,"M\",$54,$49+$80,"q",$51,"5",$57,"uvwxy/"

leet_speeks_l
    .by <leet_speek1
    .by <leet_speek2
    .by <leet_speek3
    .by <leet_speek4
leet_speeks_h
    .by >leet_speek1
    .by >leet_speek2
    .by >leet_speek3
    .by >leet_speek4
leet_screen 
    .ds 32*9
leet_screen_end 
    ini $2000
;---------------------------------------------------

    org $3000
screen
    ins 'difficulties.bmp',+62
DL
    :13 .by SKIP8
    .by MODEF+LMS
    .wo screen
    :25 .by MODEF
    .by JVB
    .wo DL
    
start
    mwa #DL dlptrs
    lda #@dmactl(standard|dma|players|missiles|lineX1)  ; normal screen width, DL on, P/M on
    sta dmactls
    mva #0 COLOR2
    sta COLBAK
    mva #15 COLOR1
    POKEY_INIT
    pause 3
    lda #0
    sta $d40e   ; NMI OFF 
    sei         ; IRQ OFF
    
    
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
    sta wsync ;------------
       ; test for going further
    lda CONSOL
    cmp #7
    bne exit_tech_diff
     ; check keyboard
    lda SKSTAT
    cmp #$f7    ; SHIFT
    beq exit_tech_diff
    cmp #$ff
    bne exit_tech_diff
    sta wsync ;------------
    lda TRIG0
    beq exit_tech_diff   
    sta wsync ;------------

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
    cpx #11
    sne:ldx #1
    jmp please_wait_loop

exit_tech_diff
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
    
;
    lda #$40
    sta $d40e   ; NMI On 
    cli         ; IRQ on
    mva #0 DMACTLS
    sta dmactl
    rts 
 
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
finito
    ini start
