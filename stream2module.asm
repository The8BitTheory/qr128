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

stream_to_module




    rts
    