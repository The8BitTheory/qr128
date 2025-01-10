#RetroDevStudio.MetaData.BASIC:8193,BASIC 65,uppercase,10,10
# END OF BASIC TEXT
3 DD=PEEK(186):SA=$07000
4 NV=83+16:DIM SC%(NV),AO%(NV),CO%(8)
10 BE=WPEEK(130)

16 DEF FN LB(ZZ)=ZZ-INT(ZZ/256)*256
17 DEF FN HB(ZZ)=INT(ZZ/256)


23 DIM CH$(15)
24 CH$(0)=CHR$(32):CH$(1)=CHR$(190):CH$(2)=CHR$(188):CH$(3)=CHR$(18)+CHR$(162)+CHR$(146)
25 CH$(4)=CHR$(187):CH$(5)=CHR$(161):CH$(6)=CHR$(18)+CHR$(191)+CHR$(146):CH$(7)=CHR$(18)+CHR$(172)+CHR$(146)
26 CH$(8)=CHR$(172):CH$(9)=CHR$(191):CH$(10)=CHR$(18)+CHR$(161)+CHR$(146):CH$(11)=CHR$(18)+CHR$(187)+CHR$(146)
27 CH$(12)=CHR$(162):CH$(13)=CHR$(18)+CHR$(188)+CHR$(146):CH$(14)=CHR$(18)+CHR$(190)+CHR$(146):CH$(15)=CHR$(18)+CHR$(32)+CHR$(146)


# UPPER BOUND OF BASIC
#4 END

#30 BLOAD"QRSPR.7000",B0
35 H$="HTTPS://"
40 T$="GITHUB.COM"

50 T$=H$+T$

60 PRINT"GENERATING QR-CODE..."
70 S=TI:BANK0

71 FOR X=1 TO LEN(T$)
72  POKE BE+X,ASC(MID$(T$,X,1))
73 NEXT:POKE BE+LEN(T$)+1,0
74 LB=FNLB(BE+1):HB=FNHB(BE+1)

75 POKE $FB,LB:POKE $FC,HB: REM INPUT ADDRESS
76 POKE $FD,$F0:POKE $FE,$01: REM SPRITE DATA TARGET ADDRESS

110 SYS SA,0,$FB,$FD

120 S=TI-S
130 RREG A
132 LB=PEEK($FB):HB=PEEK($FC):MB=PEEK($FD):F=LB+HB*256+MB*65536:L=PEEK($FE)
135 GOTO 500

140 CURSOR 40,0,0:PRINT ""T$
145 CURSOR 40,1,0:PRINT"TOOK"S"SECONDS"
150 CURSOR 40,2,0:PRINT "MATRIX AT $"HEX$(F)", L="L
160 CURSOR 40,3,0:PRINT "1-3 CHANGE MASK"
180 CURSOR 40,4,0:PRINT "N   NEW QR-CODE"
200 CURSOR 40,5,0:PRINT "X   EXIT"
210 GETKEY I$

220 IF ASC(I$)>48 THEN IF ASC(I$)<53 THEN BM=2(ASC(I$)-48):POKE (SA+7),BM:GOTO 60
240 IF I$="N" THEN 280
260 IF I$="X" THEN 310
270 GOTO 160

280 PRINT "URL TO ENCODE (WITHOUT "H$"):"
290 INPUT T$:IF T$="X" THEN END
300 GOTO 50

310 END


390 RETURN


# RENDER SPRITE
#    uint8_t  sprwidth  = 64;
#    uint8_t  sprheight = 64;
#    uint16_t sprptrs   = 0x0400;
#    uint16_t sprdata   = 0x0600;

#    VIC2.SE        = 1;          // $d015 - enable the sprite
#    VIC4.SPRPTRADR = sprptrs;    // $d06c - location of sprite pointers
#    VIC4.SPRPTR16  = 1;          // $d06e - 16 bit sprite pointers
#    VIC2.BSP       = 0;          // $d01b - sprite background priority
#    VIC4.SPRX64EN  = 1;          // $d057 - 64 pixel wide sprites
#    VIC4.SPR16EN   = 0;          // $d06b - turn off Full Colour Mode
#    VIC4.SPRHGTEN  = 1;          // $d055 - enable setting of sprite height
#    VIC4.SPR640    = 0;          // $d054 - disable SPR640 for all sprites
#    VIC4.SPRHGHT   = sprheight;  // $d056 - set sprite height to 64 pixels for sprites that have SPRHGTEN enabled
#    VIC2.SEXX      = 255;        // $d01d - enable x stretch
#    VIC2.SEXY      = 255;        // $d017 - enable y stretch
#    VIC2.S0X       = 140;        // $d000 - sprite x position
#    VIC2.S0Y       = 110;        // $d001 - sprite y position
#    VIC2.SPR0COL   = 10;         // $d027 - sprite colour

#    poke(sprptrs+0, ((sprdata/64) >> 0) & 0xff); // data for sprite 0 is at 0x0600 - low byte  of 16bit ptr
#    poke(sprptrs+1, ((sprdata/64) >> 8) & 0xff); // data for sprite 0 is at 0x0600 - high byte of 16bit ptr

#    for(uint16_t i = 0; i<(sprwidth/8)*sprheight; i++) // fill 0x0600 with checkerboard
#    {
#        uint8_t val = 0b01010101;
#        if((i/8) % 2 == 1)
#            val = 0b10101010;

#        poke(sprdata+i, val);
#    }
    
500 BANK128
501 POKE $D015,1

502 SP=$FFF0
503 WPOKE $D06C,SP

504 POKE $D06E,132
506 POKE $D01B,0
508 POKE $D057,1
510 POKE $D06B,0
512 POKE $D055,1
514 POKE $D054,0
516 POKE $D056,L+4
518 POKE $D01D,255
520 POKE $D017,255
522 POKE $D000,140
524 POKE $D001,110
526 POKE $D027,10

532 BANK4:WPOKE SP,(LB+HB*256)/64:BANK0
#534 POKE $0401,HB



999 GOTO 140

