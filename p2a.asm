; petscii to ascii conversion
; takes the result of pointer(x) as input (i). regx=loc lb, regy=loc hb, acc=length
; bank 1, peek(i) gives length of string, peek(i+1)+peek(i+2)*256 gives address of string

!to "p2a.bin",cbm

;!source <cbm/c128/kernal.a>

k_indfet = $ff74
k_indsta = $ff77


;location = $fa ;$FA-$FB. location of the string
;length = $fc   ;$FC. length of the string


;*=$1300
p2a
  ; store parameters
;  sta length
;  stx location
;  sty location+1
  
  ldy #0
  sei
  
.loop
  lda #z_location
  ldx #1
  jsr k_indfet

  ; IF A>=193 AND A<=218 THEN A=A-128
  ; < 193
  cmp #193
  bcc .comp2
  
  ; > 218
  cmp #218
  beq .comp2  
  
  ; then a=a-128
  sec
  sbc #128
  
  jmp .write
  
; IF A>=65 AND A<=90 THEN A=A+32
; a < 65
.comp2
  cmp #65
  bcc .write
  
; > 90
  cmp #90
  beq .write
  
  clc
  adc #32
  
.write
  ldx #z_location2
  stx $02b9
  
  ldx #0
  jsr k_indsta
  
  iny
  cpy contentLength
  bne .loop
  
  cli
  rts