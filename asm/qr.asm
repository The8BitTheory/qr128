; qr-code generator
; parameters:
; - reads the location of the string to be encoded from a zeropage location (eg $fb/$fc)
;   the string must be zero-terminated (that saves us the need to provide string-length as a parameter)
; - bank of the string address
; returns: location of 

;target = "mega65"
target = "c128"
renderTo = "sprite"

!if target = "c128" {
*= $3060
  !to "qr.3060.bin.prg",cbm
  
  create_runtime = 0      ; enables exporting a self-running program that outputs petscii-characters
  nr_patterns = 1
  max_version = 5
  find_var    = 0
  knows_primm = 1
  basic_aio_starter = 0

  z_location  = $fb     ;$fb-$fc for storing indexed addresses
  z_location2 = $fd     ;$fd-$fe for storing indexed addresses
  z_location3 = $bd     ;used for m_divisors in rs.a
                        ;also used for storing compressed matrix for runtime in render2.a
                        ;and for storing target bank in renderspr.a
  z_temp      = $bf
  z_counter1  = $b0     ;ENDCHR
  z_counter2  = $a3     ;CHARAC or INTEGR
  z_zp4       = z_location2

} else if target = "c64" {
*= $C000
  !to "qr64.bin.prg",cbm

  create_runtime = 1
  nr_patterns = 3
  max_version = 4
  find_var    = 1
  knows_primm = 0
  basic_aio_starter = 0
  
  z_location  = $fb     ;$fa-$fb for storing indexed addresses
  z_location2 = $fd     ;$fc-$fd for storing indexed addresses
  z_location3 = $16     ; not needed on vic-20
  z_temp      = $02
  z_counter1  = $08     ;ENDCHR
  z_counter2  = $0a     ;VERCK
  
} else if target = "vic20" {
*= $1001
  !to "qr20.bin.prg",cbm

  create_runtime = 0
  nr_patterns = 1
  max_version = 4
  find_var    = 1
  knows_primm = 0
  basic_aio_starter = 1
  
  z_location  = $fb     ;$fa-$fb for storing indexed addresses
  z_location2 = $fd     ;$fc-$fd for storing indexed addresses
  z_location3 = $16     ; not needed on vic-20
  z_temp      = $02
  z_counter1  = $08     ;ENDCHR
  z_counter2  = $0a     ;VERCK
  
} else if target = "x16" {
*= $a000
  !to "qrx16.bin",plain
  
  create_runtime = 1
  nr_patterns = 3
  max_version = 5
  find_var    = 0
  knows_primm = 0
  basic_aio_starter = 0

  z_location  = $22     ;$fb-$fc for storing indexed addresses (usually the read address)
  z_location2 = $24     ;$fd-$fe for storing indexed addresses (usually the write address)
  z_location3 = $26     ;$14-$15 LINNUM. we use this to write the "compressed" matrix
  z_temp      = $28
  z_counter1  = $29     ;ENDCHR
  z_counter2  = $30     ;VERCK
  m_divisors =  $31    ;$31-$32

} else if target = "mega65" {

; SYS maps $E000-$FFFF to the MEGA65 KERNAL (3.E000-3.FFFF),
; $2000-$7FFF to 0.2000-0.7FFF, and leaves $0000-$1FFF and $8000-$DFFF "unmapped."

; This allows $C000-$CFFF and $D000-$DFFF to fall through to INTERFACE and VIC registers, respectively
; and $8000-$BFFF to fall through to bank 0 RAM.

*= $7000
  ; 196-203 ($c4-$cb) are rs232 input- and output buffer start and end addresses
  ; these are free to use, as long as rs232 is not used

  !to "qrm65.bin",cbm
  
  create_runtime = 1
  nr_patterns = 1
  max_version = 5
  find_var    = 0
  knows_primm = 1
  basic_aio_starter = 0

  z_location  = $fb     ;$fa-$fb for storing indexed addresses
  z_location2 = $fd     ;$fc-$fd for storing indexed addresses
  
  z_location3 = $c4     ;used for m_divisors in rs.a  - stored in m_zpa3
                        ;also used for storing compressed matrix for runtime in render2.a
  z_temp      = $c6     ;-- stored in m_zpa4
  z_counter1  = $c8     ;ENDCHR   -- stored in m_zpa1
  z_counter2  = $ca     ;VERCK    -- stored in m_zpa2

}

!if basic_aio_starter {
    ;75 characters fit into RAM
    
    !byte $31,$10,$05,$00
    !byte $54,$24,$b2,$22
    !pet "https://github.com/the8bittheory/qr128"
    ;!pet "forum64.de"
    !byte $22,$00
    
    ;15 poke,poke,print
    !byte $54,$10,$0f,$00,$97
    !pet "36879,1"
    !byte $3a,$97
    !pet "646,1"
    !byte $3a,$99,$22,$93,$22,$3a,$97,$32,$31,$34,$2c,$31,$36,$3a,$99,$00
    ;poke 21
    
    ;20 poke
    !byte $6e,$10,$14,$00,$97,$37,$38,$30,$2c,$c6,$28,$22,$54,$22,$29
    !byte $3a
    !byte $99,$54,$24,$3a
    
    ;!basic 40,start
    ;!byte $83,$10,$28,$00,
    !byte $9e
    !byte '0' + start % 10000 / 1000
    !byte '0' + start % 1000 / 100
    !byte '0' + start % 100 / 10
    !byte '0' + start % 10
    !byte $00
    
    ;input t$
    !byte $98,$10,$3c,$00,$85,$54,$24,$3a,$89,$31,$35,$00
    
    !byte $00,$00
}



    ;jmp .generate
    ;jmp save


    ;cpx #0
    ;beq +     ;x-reg not set, ie no maskbit provided. go with default value of 2 (set down below)
    ;stx render.m_maskbit
start
;!if find_var {
;    jsr findvar
;}
    jsr init
    bcs .too_long
    bcc +
    
m_maskbit    !byte 2
    
+   jsr p2a
    jsr bytes_to_stream
    jsr calc_xor_masks
    jsr rs
    jsr write_patterns
    jsr stream_to_module

; load screen-ram location into z_location2    
!if target = "x16" {
    lda #<*+4096
    sta z_location2
    lda #>*+4096
    sta z_location2+1
    
    ldx #$80
    stx rsDivisorOffset
    
} else if target = "mega65" {
; z_location2 = location to write to
    lda $d060
    sta z_location2
    lda $d061
    sta z_location2+1
    
    ldx #80
    stx rsDivisorOffset
} else {
    ;set screenram
    lda #$0
    sta z_location2
    lda $0a3b
    sta z_location2+1
    ;set linesize (use rsDivisorOffset because we don't need it any longer at this stage)
    ldx $ee
    inx
    stx rsDivisorOffset
}

    ; z_location3 points to the runtime data
    ; m_compWritePos holds the length of the runtime
    
!if renderTo = "sprite" {  
    jsr renderspr
; z_location2 points to the pixel data

    ldx z_location2   ;these are set in renderspr
    stx $fd
    ldy z_location2+1
    sty $fe
} else {
    jsr render
}

    lda z_counter2
    sta $fd

    
    ;recover zeropage values
    lda m_zpa1
    sta z_counter1
    lda m_zpa1+1
    sta z_counter1+1
    
    lda m_zpa2
    sta z_counter2
    lda m_zpa2+1
    sta z_counter2+1
    
    lda m_zpa4
    sta z_temp
    lda m_zpa4+1
    sta z_temp+1
    

    
!if create_runtime = 1 {
    ; write location of runtime data to X and Y registers
    ldx z_location3
    ldy z_location3+1

    ; restore original value of z_location3
    lda m_zpa3
    sta z_location3
    lda m_zpa3+1
    sta z_location3+1
}

!if renderTo = "char" {    
    lda contentLength
} else {
    lda size
}
    
    rts
    
    ;content too long
.too_long
    lda #0
    rts
         
size            !byte 0   ;size of one axis-length of the final matrix
contentLength   !byte 0   ;size of the provided URL, also used when writing the "compressed" matrix in render2.a
eccLength       !byte 0   ;nr of ecc bytes to generate  
streamLength    !byte 0 
matrixSize      !byte 0,0 ;size of the matrix in modules (1 byte per module)
rsDivisorOffset !byte 0
m_xpos          !byte 0
m_ypos          !byte 0
m_zpa1          !word 0
m_zpa2          !word 0
m_zpa3          !word 0
m_zpa4          !word 0
!if renderTo = "sprite" {
spriteOut       !word 0
}

!source "common.a"

!if find_var {
  !source "var.a"
}

!source "init.a"
!source "p2a.a"           ; reads petscii bytes from z_location and writes ascii to z_location2 (which is matrix-start)
!source "bytes2stream.a"    ; reads ascii from z_location2 and writes into datastream at z_location (=data+matrix_size)
                            ; z_counter1 holds the right offset for rs.a to continue using it.
!source "masks.a"           ; this clears the matrix memory area and calculates all the xor-masks
!source "rs.a"              ; reads content bytes from datastream (z_location) and writes ecc bytes to 
                            ; z_location2(=z_location + z_counter1)
!source "patterns.a"        ; this writes timing, alignment, finder patterns etc.
!source "stream2module.a"

!if renderTo = "sprite" {
  !source "renderspr.a"
} else {
  !source "render2.a"
}

;!source "fsave.a"


data    !byte 0