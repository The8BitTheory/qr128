
!to "qr.bin.prg",cbm

k_primm = $ff7d

z_location  = $fa          ;$fa-$fb for storing indexed addresses
z_location2 = $fc         ;$fc-$fd for storing indexed addresses
z_temp      = $fe
z_counter1  = $0a     ;ENDCHR
z_counter2  = $0c     ;VERCK

*= $1300

    jmp init
    jmp p2a
    jmp bytes_to_stream
    jmp rs
    jmp stream_to_module
    rts
    
size            !byte 0   ;size of one axis-length of the final matrix
contentLength   !byte 0
eccLength       !byte 0   ;nr of ecc bytes to generate
streamLength    !byte 0
matrixSize      !byte 0,0 ;size of the matrix in modules (1 byte per module)
;counter1        !byte 0
;counter2        !byte 0

    
; this calculates all sizes according to the length of the content
; accumulator holds length
; x holds bank 1 address lb
; y holds bank 1 address hb
init
    sta contentLength
    
    ; input address for petscii-to-ascii conversion
    stx z_location
    sty z_location+1
    
    ; output address for petscii-to-ascii conversion
    ldx #<data
    stx z_location2
    ldx #>data
    stx z_location2+1
    
    
;calculate version.
    ; decreasing the version boundaries by one byte, because of mode and length bits (eg lower than 108)
    ; max supported version is 5 -> 108 bytes -2=106
    cmp #18
    bcs +
    lda #21
    sta size
    lda #<441
    sta matrixSize
    lda #>441
    sta matrixSize+1
    lda #7
    sta eccLength
    lda #26
    sta streamLength
    
+   cmp #33
    bcs +
    lda #25
    sta size
    lda #<625
    sta matrixSize
    lda #>625
    sta matrixSize+1
    lda #10
    sta eccLength
    lda #44
    sta streamLength
    
+   cmp #54
    bcs +
    lda #29
    sta size
    lda #<841
    sta matrixSize
    lda #>841
    sta matrixSize+1
    lda #15
    sta eccLength
    lda #70
    sta streamLength
    
+   cmp #79
    bcs +
    lda #33
    sta size
    lda #<1089
    sta matrixSize
    lda #>1089
    sta matrixSize+1
    lda #20
    sta eccLength
    lda #100
    sta streamLength
    
+   cmp #107
    bcs +
    lda #37
    sta size
    lda #<1369
    sta matrixSize
    lda #>1369
    sta matrixSize+1
    lda #26
    sta eccLength
    lda #134
    sta streamLength
    
    jmp ++

; content too long for this    
+   jsr k_primm
    !pet "Content is too long.",0
    
; done
++  rts


!source "p2a.asm"
!source "bytes2stream.a"
!source "rs.asm"
!source "stream2module.asm"
!source "masks.asm"

data    !byte 0