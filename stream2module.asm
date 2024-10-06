; this writes the bytes of the datastream into the matrix that's finally to become the qr-code
; this still needs to be ORed accordingly to become a valid qr-code

; procedure
; - read bit by bit from datastream bytes
; - after each written bit (1=dark, 0=light), advance the write index in a zig-zag pattern
; - column 6 is always excluded and holds no information, as it only holds the administrative patterns
; 
; variables needed
; - writeIndex. starts at right-bottom corner (eg 1368 in a 0-based array). each module is a full byte
; - current write direction. can be up or down
; - current column index
; 

z_datastream =       $fa  ;$fa-$fb - pointer to the address where to write the bits to (length 108)
z_output =           $fc  ;$fc-$fd - pointer to the address where to write the final output matrix to (length 1369)
z_temp =             $fe  ;$fe. temp
z_dsoffset =         $0a  ;$0a. acts as a permanent location for the position in y-reg when working with z_datastream

; all of the following values should be a variables, not hardcoded
writeOffset  =      1368  ;last module of the matrix. TODO: needs to be added to base-address to be correct
writeDirection =       1  ;1=up, 0=down
curCol         =      36  ;current Column
streamLength =       108  ;length of datastream.
axisLength =          37  ; 

m_startAddress =   $03e4  ;$03e4-$03e5. absolute address of where output starts. used for comparisons
m_endAddress  =    $03e6  ;$03e6-$03e7. absolute address of where output ends. used for comparisons
m_curCol      =    $03e8  ;$03e6. current column to be written to
m_writeDirection = $03e9  ;$03e7. are we moving up or down when writing modules. 1=up, 0=down
m_streamLength =   $03ea  ;$03e8. length of datastream. (mode-bits, length-bits, content-bits, padding-bits, ecc-bits)
m_one            = $03eb  ;holds the value 1. used for BIT operation
m_128            = $03ec  ;holds the value 128. used for BIT operation

!to "stream2mod.bin",cbm
*= $1306

stream_to_module

    lda #$aa
    sta z_datastream
    lda #$3a
    sta z_datastream+1
    
    clc
    lda #$34
    sta m_startAddress
    adc #<writeOffset
    sta z_output
    sta m_endAddress
    
    lda #$30
    sta m_startAddress+1
    adc #>writeOffset
    sta z_output+1
    sta m_endAddress

    ;sta z_datastream
    ;stx z_datastream+1
    

    
    lda #curCol
    sta m_curCol
    
    lda #writeDirection
    sta m_writeDirection

    lda #streamLength
    sta m_streamLength
    
    lda #1
    sta m_one
    
    lda #128
    sta m_128

    ; walk over bytes of datastream, split them into bits and write these as modules
    ldy #0
    
--  ldx #128                
    stx z_temp              ;use for bit-comparison and shift left
  
-   lda (z_datastream),y
    bit z_temp
    bne +
    lda #%01000001                 ;bit 6 set means data-module. bit 0 set means dark module
    jmp ++
+   lda #%01000000                 ;bit 6 means data-module. bit 0 clear means light module
    
++  sty z_dsoffset
    jsr writeAndAdvance
    ldy z_dsoffset

    lda z_temp
    lsr
    sta z_temp
    bne -
    
    iny
    cpy #streamLength
    bne --
    

    rts
    
; writes the accumulator to the current write offset and then calculates the next offset position
writeAndAdvance
    ldx #0
    sta (z_output,x)
    
    ; where are we in relation to column 6? (col 6 is skipped and it changes even-odd behavior of offset pos calc)
    lda m_curCol
    cmp #6
    bcs .advGt6     ;carry-flag set: col is larger than 6
    jmp .advLt6     ;else: col is lower than 6
                    ;if col equals 6, we also handle it as lower than 6, as this will skip the column

    rts

; do we advance in a column > 6 or <= 6?
.advGt6
    bit m_one  
    beq .advWriteIdx1 ; odd columns go diagonal up or down next
    jmp .advWriteIdx2 ; even columns go left first

        
.advLt6
    bit m_one  
    beq .advWriteIdx2 ; even columns go left first
    jmp .advWriteIdx1 ; odd columns go diagonal up or down next


; go one column to the left. that's -1 in the matrix and -1 for col
.advWriteIdx1
    dec z_output
    bpl +
    dec z_output+1
    
+   dec m_curCol

    ; check value of the new output location. if it's not 128, it's occupied already and we need to keep advancing
    ldx #0
    lda (z_output,x)
    bit m_128
    bne .advWriteIdx2

    rts

; advance diagonal. makes a difference whether we go up or down
.advWriteIdx2
    lda m_writeDirection
    bit m_one
    beq .advUp
    jmp .advDown

.advUp
    ;move one row up and one module to the right
    ;z_output=z_output-axislength+1
    sec
    lda z_output
    sbc axisLength
    sta z_output
    bcs +
    dec z_output+1

+   clc
    lda z_output
    adc #1
    sta z_output
    bcc +
    inc z_output+1
    
; check if we moved outside of the matrix (ie went to before the first row). if output < m_startAddress: change direction
+   lda z_output+1
    cmp m_startAddress+1
    bcc .changeDirectionToDown
    
    lda z_output
    cmp m_startAddress
    bcc .changeDirectionToDown
    
    ; not changing direction. update col and check if new location is occupied

.endAdvWriteIdx2
    inc m_curCol
    
    ldx #0
    lda (z_output,x)
    bit m_128
    bne .advWriteIdx1
    
    ; new location not occupied. we're done.
    rts
    

.changeDirectionToDown    
    ;W=W+L-2:D=0:C=C-2
    clc
    lda z_output
    adc axisLength
    sta z_output
    bcc +
    inc z_output+1
    
+   sec
    sbc #2
    sta z_output
    bcs +
    dec z_output+1

    ; write new direction
+   lda #0
    sta m_writeDirection
    
    ; update column information
    dec m_curCol
    dec m_curCol
    
    jmp .endAdvWriteIdx2


.advDown
    ; move one row down and one module to the right
    ;W=W+L+1
    clc
    lda z_output
    adc axisLength
    sta z_output
    bcc +
    inc z_output+1
    
+   clc
    adc #1
    sta z_output
    bcc +
    inc z_output+1

; check if we moved outside of the matrix (ie went to past the last row). if output > m_endAddress: change direction
+   lda z_output+1
    cmp m_endAddress+1
    bcs .changeDirectionToUp
    
    lda z_output
    cmp m_endAddress
    bcs .changeDirectionToUp
    
    rts
    
.changeDirectionToUp
    ;W=W-L-2:D=-1:C=C-2
    sec
    lda z_output
    sbc axisLength
    sta z_output
    bcs +
    dec z_output+1
    
    sec
+   sbc #2
    sta z_output
    bcs +
    dec z_output+1
    
+   lda #1
    sta m_writeDirection
    
    dec m_curCol
    dec m_curCol
    
    jmp .endAdvWriteIdx2
    
    
    
    
    
    
    