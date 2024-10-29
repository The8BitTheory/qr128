;view qrcode file

z_temp          = $fa
z_location      = $fb     ;$fb-$fc
z_location2     = $fd     ;$fd-$fe

z_readoff       = $02
z_writeoff      = $08     ;ENDCHR
z_lines_left    = $0a     ;VERCK

*=$c000
    stx z_location
    sty z_location+1

    ;set screenram
    lda #$0
    sta z_location2
    lda $0288
    sta z_location2+1
    ;set linesize (use rsDivisorOffset because we don't need it any longer at this stage)
    ldx $d5
    inx
    stx .m_screen_width
    
    
    ldy #0
    sty z_writeoff          ;write offset. writes a line, reset to zero, increase z_location2 by size
    
    lda (z_location),y
    iny
    sty z_readoff           ;read offset. continuous until end of file
    
    clc
    adc #1
    lsr
    sta z_lines_left
    sta .m_size
    ;inc .m_size
        
-   ldy z_readoff
    lda (z_location),y      ;z_location points to the datafile (containing screen codes, each byte is a 2x2 petscii character)

    sta z_temp
    ;get higher nybble
    lsr
    lsr
    lsr
    lsr
    
    jsr render_char
    bcs .end

    lda z_temp
    and #$F

    jsr render_char
    
    inc z_readoff
    
    jmp -
    
    
.end
    rts


render_char
    tax
    lda .modulechars,x
    ldy z_writeoff
    sta (z_location2),y
    iny
    cpy .m_size
    bne +
    
    dec z_lines_left
    beq .done
    
    ldy #0
    sty z_writeoff
    lda z_location2
    clc
    adc .m_screen_width
    sta z_location2
    bcc +
    inc z_location2+1

+   sty z_writeoff
    
    clc
    rts
    
.done
    sec
    rts

.modulechars      !byte 32,126,124,226,123,97,255,236,108,127,225,251,98,252,254,160
.m_size           !byte 0
.m_screen_width   !byte 0

