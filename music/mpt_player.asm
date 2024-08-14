
/*
  Player MPT 2.4
  coded by Fox
  07,19,25,30/07/96
  original version by Jaskier/Taquart
*/

.proc   mpt_player

;msx	equ $5000
;lenpat	equ $20
;speed	equ $03

zp	equ $f0		;12 bytes on page 0

freq	equ zp		;(4)
slup	equ zp+4	;(4)
ad	equ zp+8	;(2)
aud	equ zp+10	;(1)
tp	equ zp+11	;(1)


play
 ldx freq
 ldy freq+1
 lda aud
 sta $d208
 sta $d218
 and #$10
v10 equ *-1
 beq w1
 ldy numdzw+1
 ldx bsfrql,y
 lda bsfrqh,y
 tay
w1 stx $d210
 stx $d200
 sty $d212
 sty $d202
 lda freq+2
 sta $d214
 sta $d204
 lda freq+3
 sta $d216
 sta $d206
 lda volume
 sta $d211
 sta $d201
 lda volume+1
 sta $d213
 sta $d203
 lda volume+2
 sta $d215
 sta $d205
 lda volume+3
 sta $d217
 sta $d207

 ldx #0
 stx aud
 inc licz
 lda #$ff
pozptr equ *-1
l00 cmp #?lenpat
 dec zegar
 bcc r1
 beq *+5
 jmp r5
 stx pozptr
p2 lda #$ff
 sta ptrwsk,x
 sta licspc,x
m_01c0 lda msx+$1c0,x
 sta ad
m_01c4 lda msx+$1c4,x
 sta ad+1
 ldy #0
pozsng equ *-1
p3 lda (ad),y
 iny
 cmp #$fe
 bcc p6
 beq p4
 lda (ad),y
 bmi p4
 asl @
 tay
 sta pozsng
 bcc p3
p6 asl @
 sta numptr,x
 lda (ad),y
 sta poddzw,x
p7 inx
 cpx #4
 bcc p2
 iny
 sty pozsng
 bcs r5
p4 ldx #3
 lda #0
fin sta volume,x
 dex
 bpl fin
 dec pozptr
 inc zegar
ret rts		;tutaj konczy player

r1 bpl r5
 ldx #3
r2 dec licspc,x
 bpl r4
 ldy numptr,x
m_0041 lda msx+$41,y
 beq r4
 sta ad+1
m_0040 lda msx+$40,y
 sta ad
 ldy ptrwsk,x
 jmp newdzw
r3 lda ilespc,x
 sta licspc,x
r4 dex
 bpl r2
 lda #?speed-1
tempo equ *-1
 sta zegar
 inc pozptr

r5 ldx #3
 bne r6

d0 sta volume,x
 jmp r9

r8 ldy #$23
 lda (ad),y
 ora aud
 sta aud
 lda (ad),y
 and filtry,x
 beq r9
 ldy #$28
 lda (ad),y
 clc
 adc numdzw,x
 jsr czest
 sec
 adc p1pom,x
 sta freq+2,x
r9 dex
 bmi ret
r6 lda adrinh,x
 beq d0
 sta ad+1
 lda adrinl,x
 sta ad
 ldy slup,x
 cpy #$20
 bcs d3
 lda (ad),y
 adc adcvol,x
 bit v10
 beq d1
 and #$f0
d1 sta volume,x
 iny
 lda (ad),y
 iny
 sty slup,x
 sta tp
 and #7
 beq d4
 tay
 lda akce-1,y
 sta akbr+1
 lda tp
 lsr @
 lsr @
 lsr @
 lsr @
 lsr @
 ora #$28
 tay
 lda (ad),y
 clc
akbr bcc *
ak equ *

a0 adc freq,x
a1 sta freq,x
 jmp r9
a2 jsr aczest
 sta freq,x
 jmp r9
a4 sta freq,x
 lda ndziel,x
 bpl a7
a5 sta freq,x
 lda #$80
 bne a7
a6 sta freq,x
 lda #1
a7 ora aud
 sta aud
 jmp r9
a8 and $d20a
 sta freq,x
 jmp r9

d3 iny
 iny
 bne *+4
 ldy #$20
 sty slup,x
 lda volume,x
 and #$0f
 beq d4
 ldy #$22
 lda (ad),y
 beq d4
 dec p3lic,x
 bne d4
 sta p3lic,x
 dec volume,x
d4 lda slup,x
 and #6
 lsr @
 adc #$24
 tay
 lda (ad),y
 jsr aczest
 sta freq,x
 ldy branch,x
 sty typbr+1
 ldy p2lic,x
typbr beq *
so equ *
 dec p2lic,x
 jmp r8

s0 lda #2
 and #0
licz equ *-1
 beq t2
 asl @
 and licz
 bne t0
 lda p1lsb,x
t1 sta p1pom,x
 adc freq,x
 sta freq,x
 jmp r8
t0 lda freq,x
s1 sec
 sbc p1lsb,x
 sta freq,x
 tya 		;#0
 sec
 sbc p1lsb,x
t2 sta p1pom,x
 jmp r8
s2 lda p1lic,x
t9 sta p1pom,x
 clc
 adc freq,x
t3 sta freq,x
 clc
 lda p1lic,x
 adc p1lsb,x
 sta p1lic,x
 jmp r8
s3 lda numdzw,x
 sec
 sbc p1lic,x
t4 jsr nczest
 jmp t3
s4 tya		;#0
 sec
 sbc p1lic,x
 jmp t9
s5 lda numdzw,x
 clc
 adc p1lic,x
 jmp t4
s6 jsr t5
 jmp t1
s7 jsr t5
 adc numdzw,x
 jsr nczest
 sta freq,x
 jmp r8
t5 ldy p1lic,x
 lda p1lsb,x
 bmi *+4
 iny
 iny
 dey
 tya
 sta p1lic,x
 cmp p1lsb,x
 bne t7
 eor #$ff
 sta p1lsb,x
 lda p1lic,x
t7 clc
 rts
aczest adc adcdzw,x
nczest sta numdzw,x
czest and #$3f
 ora frqwsk,x
 tay
m_00c0 lda msx+$c0,y
 rts

nins sty tp
 and #$1f
 asl @
 tay
m_0000 lda msx,y
 sta adrinl,x
m_0001 lda msx+1,y
 sta adrinh,x
 ldy tp
newdzw lda #0
newavo sta adcvol,x
new iny
 lda (ad),y
 bpl q4
 cmp #$fe
 bne q0
 tya
 sta ptrwsk,x
 jmp r3
q0 cmp #$c0
 bcc q3
 cmp #$e0
 bcc q1
l01 lda #?lenpat
 sta pozptr
 bcs new
q1 cmp #$d0
 bcc q2
 and #$0f
 sta tempo
 bpl new
q2 adc #$31
 bvc newavo
q3 and #$3f
 sta ilespc,x
 bpl new
q4 cmp #$40
 bcs nins

 adc poddzw,x
 sta adcdzw,x
 tya
 sta ptrwsk,x
 lda adrinh,x
 beq qret
 sta ad+1
 lda adrinl,x
 sta ad
 ldy #$20
 lda (ad),y
 and #$0f
 sta p1lsb,x
 lda (ad),y
 lsr @
 lsr @
 lsr @
 lsr @
 and #7
 tay
 lda typy,y
 sta branch,x
 ldy #$21
 lda (ad),y
 asl @
 asl @
 sta tp
 and #$3f
 sta p2lic,x
 eor tp
 sta frqwsk,x
 iny
 lda (ad),y
 sta p3lic,x
 lda #0
 sta slup,x
 sta p1lic,x
 sta p1pom,x
 lda adcdzw,x
* (nczest)
 sta numdzw,x
 and #$3f
 ora frqwsk,x
 tay
m_00c0_ lda msx+$c0,y
 sta freq,x
qret jmp r3

akce
 dta b(a1-ak),b(a0-ak),b(a2-ak)
 dta b(a4-ak),b(a5-ak),b(a6-ak),b(a8-ak)

typy
 dta b(s0-so),b(s1-so),b(s2-so),b(s3-so)
 dta b(s4-so),b(s5-so),b(s6-so),b(s7-so)

ndziel dta $40,$00,$20,$00

filtry dta $04,$02,$00,$00

bsfrql equ *-1
 dta $f2,$33,$96,$e2,$38,$8c,$00
 dta $6a,$e8,$6a,$ef,$80,8,$ae,$46
 dta $e6,$95,$41,$f6,$b0,$6e,$30,$f6
 dta $bb,$84,$52,$22,$f4,$c8,$a0,$7a
 dta $55,$34,$14,$f5,$d8,$bd,$a4,$8d
 dta $77,$60,$4e,$38,$27,$15,$06,$f7
 dta $e8,$db,$cf,$c3,$b8,$ac,$a2,$9a
 dta $90,$88,$7f,$78,$70,$6a,$64,$5e

bsfrqh equ *-1
 dta 13,13,12,11,11,10,10,9,8,8,7,7,7,6,6,5,5,5,4,4,4,4
 dta 3,3,3,3,3,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1
 dta 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

branch dta d'    '
volume dta d'    '
adcvol dta d'    '
frqwsk dta d'    '
adcdzw dta d'    '
poddzw dta d'    '
adrinl dta d'    '
adrinh dta d'    '
numdzw dta d'    '
numptr dta d'    '
ptrwsk dta d'    '
ilespc dta d'    '
licspc dta d'    '
p1lsb  dta d'    '
p1lic  dta d'    '
p1pom  dta d'    '
p2lic  dta d'    '
p3lic  dta d'    '
zegar  dta 1

.endp
