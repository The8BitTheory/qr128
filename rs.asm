; reed-solomon error correction calculation for use in qr-codes
; acc takes zp-address pointing to memory of the datastream (108 bytes long)
; regx takes zp-address pointing to memory address of final output (26 bytes long)

; the result of this is 26 ecc bytes written


;!to "reedsolomon.bin",cbm

;!source <cbm/c128/kernal.a>

; calling this routine (paramters: datastream, output)

;5 DEF FN HB(ZZ)=DEC(MID$(HEX$(ZZ),3,1))
;6 DEF FN LB(ZZ)=DEC(RIGHT$(HEX$(ZZ),1))
; 10 rem write locations of dataStream and Output
; 20 ls=15018:lo=ld+26
; 40 poke dec("fa"),fn lb(ls):poke dec("fb"),fn hb(ls)
; 50 poke dec("fc"),fn lb(lo):poke dec("fd"),fn hb(lo)

k_indfet = $ff74
k_indsta = $ff77

z_datastream =  $fa   ;$fa-$fb - pointer to the address where to write the bits to (length 108)
z_rsresult =    $fc   ;$fc-$fd - holds the intermediary and final result of reed solomon fec calculation

divisor    =   $03e4   ; current divisor
rsfactor =     $03e5

rsmulres =     $03e6   ; result of rs-multiply
rsmul1 =       $03e7   ; rs-multiply temp var 1
rsmul2 =       $03e9   ; rs-multiply temp var 2

ds_offset =    $03eb   ; rs-remainder temp var 1
ds_loop_left = $03ec   ; rs-remainder temp var 2
loopc =        $03ed   ; loop counter in rsremainder for the loop that contains rsmultiply

rsmulx =       $03ee   ; store and recover x-reg here when calling rsmultiply
rsmuly =       $03ef   ; store and recover y-reg here when calling rsmultiply

;*= $1300
rs
    sta z_datastream
    stx z_datastream+1

    lda #$1a
    sta z_rsresult
    lda #$30
    sta z_rsresult+1
    
    ; clear result area
    ldy #26
    lda #0
-   sta (z_rsresult),y
    dey
    bpl -
    
    ;lda #<datastream
    ;sta z_datastream
    ;lda #>datastream
    ;sta z_datastream+1

    ;ldy #datastream_end-datastream
    ldy #108
    sty ds_loop_left
    
    ldy #0
    sty ds_offset

rsremainder:
    ldy ds_offset
    lda (z_datastream),y
    
    ldx #0
    eor (z_rsresult,x)
    sta rsfactor
    
    ldy #0
    ; remove first element from result-array
    ldx #25
-   iny
    lda (z_rsresult),y
    dey
    sta (z_rsresult),y
    
    iny
    
    dex
    bne -
    
    ; add zero to last position
    lda #0
    sta (z_rsresult),y
    
    ldx #26
    stx loopc
    ldy #0
    
-   lda rsdivisors,y
    sta divisor

    jsr rsmultiply
    
    eor (z_rsresult),y
    sta (z_rsresult),y
    
    iny
    dex
    bpl -
    
    dec ds_loop_left
    beq end
    
    inc ds_offset
    jmp rsremainder
    
    ; first couple of expected results
    ;dec 189 111 113 25 53 199 80 81 231 158 35
    ;hex  bd  6f  71 19 35  c7 50 51  e7  9e 23
    
end:
    rts
    
    ;xreg=factor, acc=divisor (y in basic)
rsmultiply:

    stx rsmulx
    sty rsmuly
    
    lda #0
    sta rsmulres
    
    ldy #7
    
--  clc
    asl
    sta rsmul1       ; B in the Basic implementation
    bcc +
    inc rsmul1+1
    
+   lda rsmulres     ; R in the Basic implementation
    and #128
    cmp #128            ; C=INT(R/128)
    
    bne +
    ;c=c*285
    lda #$1d
    sta rsmul2
    
    lda #$01
    sta rsmul2+1
    jmp ++
    
+   sta rsmul2
    sta rsmul2+1
    
    ;r=xor(b,c)
++  lda rsmul1
    eor rsmul2
    sta rsmulres
    
    ;----------------
    
    ;factor >>> i
    tya
    tax
    
    lda rsfactor
    cpx #0
    beq +
-   lsr
    dex
    bne -
    
    ;B=B AND 1
+   and #1
    sta rsmul1

    beq +
    
    lda divisor
    
    ;B=B*X
    
+   sta rsmul1
    
    ;R=XOR(R,B) AND 255
    eor rsmulres
    sta rsmulres

    dey
    bpl --
    
    ldx rsmulx
    ldy rsmuly

    rts
    

rsdivisors
    !byte 246,51,183,4,136,98,199,152,77,56,206,24,145,40,209,117
    !byte 233,42,135,68,70,144,146,77,43,94
    
;datastream
;    !byte 65,166,135,71,71,7,51,162,242,247,119,119,114,230,71,150,230
;    !byte 23,71,38,22,54,82,230,54,246,210,240,236,17,236,17,236,17,236
;    !byte 17,236,17,236,17,236,17,236,17,236,17,236,17,236,17,236,17,236
;    !byte 17,236,17,236,17,236,17,236,17,236,17,236,17,236,17,236,17,236
;    !byte 17,236,17,236,17,236,17,236,17,236,17,236,17,236,17,236,17,236
;    !byte 17,236,17,236,17,236,17,236,17,236,17,236,17,236,17,236,17,236
;    !byte 17 
;datastream_end
