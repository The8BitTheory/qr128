; this writes the bytes of the datastream into the matrix that's finally to become the qr-code
; this still needs to be ORed accordingly to become a valid qr-code

; procedure
; - read bit by bit from datastream bytes
; - after each written bit (1=dark, 0=light), advance the write index in a zig-zag pattern
; - column 6 is always excluded and holds no information, as it only holds the administrative patterns
; 
; variables needed
; - writeIndex. starts at right-bottom corner (eg 1368 in a 0-based array)
; - current write direction. can be up or down
; - current column index
; 

z_datastream =  $fa   ;$fa-$fb - pointer to the address where to write the bits to (length 108)
z_output =    $fc     ;$fc-$fd - pointer to the address where to write the final output matrix to (length 1369)
z_temp = $fe

; all of the following values should be a variables, not hardcoded
writeOffset  =   1369    ; last module of the matrix. TODO: needs to be added to base-address to be correct
writeDirection = 1    ; 1=up, 0=down
curCol         = 36   ; current Column
streamLength = 108    ; length of datastream.

!to "stream2mod.bin",cbm
*= $1300

stream_to_module

    lda #$aa
    sta z_datastream
    lda #$3a
    sta z_datastream+1

    ;sta z_datastream
    ;stx z_datastream+1


    ldy #0
    
--  ldx #128
    stx z_temp
  
-   lda (z_datastream),y
    bit z_temp
    bne +
    ldx #65
    jmp ++
+   ldx #64
++  jsr advWriteOffset

    lda z_temp
    lsr
    sta z_temp
    bne -
    
    dey
    bne --
    

    rts
    
advWriteOffset
    stx writeOffset

    rts
    