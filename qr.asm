
!to "qr.bin.prg",cbm

*= $1300

jmp p2a
jmp rs
jmp stream_to_module
rts

!source "p2a.asm"
!source "rs.asm"
!source "stream2module.asm"
