#RetroDevStudio.MetaData.BASIC:7169,BASIC V7.0,uppercase,10,10

4 GRAPHIC1:GRAPHIC0:COLOR 0,2:COLOR4,2:COLOR5,1
5 BLOAD"QR.BIN",B0
6 H$="HTTPS://"
10 T$="GITHUB.COM/THE8BITTHEORY/QR128"
#10 T$="FORUM64.DE/INDEX.PHP?THREAD/141120-HALLOWEEN-LEVTY-SPEZIAL-GRUSELSCHOCKER-TURNIER/"
#15 POKE 53280,1:POKE 53281,1:POKE646,0:BM=2

15 DIM SC%(115),CO%(4)
16 DEF FN LB(ZZ)=ZZ-INT(ZZ/256)*256
17 DEF FN HB(ZZ)=INT(ZZ/256)

25 T$=H$+T$

35 PRINT"GENERATING QR-CODE..."
40 S=TI

42 I=POINTER(T$)
44 BANK1:I1=PEEK(I+1):I2=PEEK(I+2):I=PEEK(I):BANK15

45 GRAPHIC0:SYS DEC("1300"),I,I1,I2:RREGA,X,Y:GRAPHIC5


114 S=TI-S

120 PRINT "TOOK"S"JIFFIES"
121 PRINT:PRINT:PRINT:PRINT T$

150 PRINT "1-4 CREATE QR-CODE WITH SPEC BITMASK"
152 PRINT "S   SAVE QR-CODE RUNTIME TO DISK"
154 PRINT "R   SAVE RAW QR-CODE BITS TO DISK"
155 PRINT "N   NEW QR-CODE"
156 PRINT "X   EXIT"

160 GET I$:IF I$="" THEN 160
161 IF ASC(I$)>48 THEN IF ASC(I$)<53 THEN BM=2(ASC(I$)-48):POKEDEC("1BFC"),BM:GOTO 35
162 IF I$="S" THEN 1000
163 IF I$="N" THEN 170
164 IF I$="X" THEN 195
169 GOTO 150


170 PRINT "URL TO ENCODE (WITHOUT "H$"):"
180 INPUT T$:IF T$="X" THEN END
190 GOTO 25

195 F=X+Y*256:L=A
196 PRINT "MATRIX AT"F", L="L
199 END


# SAVE FILE
1000 GOSUB 9000:AS=X+Y*256:AE=AS+A
1005 PRINT "QRCODE FROM "AS" TO "AE" ("A" BYTES LONG)"
#1010 BSAVE"@QRCODE",U8,B0,P(AD) TO P(AE)
#1020 GOTO 150
1100 INPUT "START ADDRESS OF QR-RUNTIME";I$
1110 VL=VAL(I$)
1115 IF VL=49152 THEN 1140

1120 V1=VL+116:V2=VL+61:V3=VL+100
1125 L1=FNLB(V1):H1=FNHB(V1)
1126 L2=FNLB(V2):H2=FNHB(V2)
1127 L3=FNLB(V3):H3=FNHB(V3)

1130 SC%(CO%(0))=L1:SC%(CO%(0)+1)=H1
1131 SC%(CO%(1))=L1:SC%(CO%(1)+1)=H1
1132 SC%(CO%(2))=L2:SC%(CO%(2)+1)=H2
1133 SC%(CO%(3))=L2:SC%(CO%(3)+1)=H2
1134 SC%(CO%(4))=L3:SC%(CO%(4)+1)=H3

1140 BANK15:BE=PEEK(4624)+PEEK(4625)*256
1145 BANK0:DE=BE:REM DE=BE+2
#1146 POKE BE,FNLB(VL):POKEBE+1,FNHB(VL)
1150 FOR X=0 TO 115
1155  POKE DE+X,SC%(X)
1160 NEXT

1165 DE=DE+115

1170 FOR X=0 TO A
1175  POKE DE+X,PEEK(AS+X)
1180 NEXT

1190 DE=DE+A:BANK15
1195 PRINT "BSAVE FROM "BE" TO "DE

1200 BSAVE("@QRCODE"+STR$(VL)),U8,B0,P(BE)TOP(DE)

1999 GOTO 150



9000 RESTORE
9005 CO=0
9010 FOR X=0TO115
9020  READ D
9030  SC%(X)=D
9035  IF D=192 THEN CO%(CO)=X-1:CO=CO+1
9040 NEXT




9050 RETURN

10000 DATA 134, 253, 132, 254, 141, 19, 3, 160
10001 DATA 0, 132, 252, 162, 0, 189, 116, 192
10002 DATA 232, 134, 251, 24, 105, 1, 74, 141
10003 DATA 17, 3, 141, 18, 3, 166, 251, 189
10004 DATA 116, 192, 141, 16, 3, 74, 74, 74
10005 DATA 74, 32, 61, 192, 176, 14, 173, 16
10006 DATA 3, 41, 15, 32, 61, 192, 230, 251
10007 DATA 162, 1, 208, 225, 96, 170, 189, 100
10008 DATA 192, 164, 252, 145, 253, 200, 204, 18
10009 DATA 3, 208, 19, 206, 17, 3, 240, 18
10010 DATA 165, 253, 24, 109, 19, 3, 133, 253
10011 DATA 144, 2, 230, 254, 160, 0, 132, 252
10012 DATA 24, 96, 56, 96, 32, 126, 124, 226
10013 DATA 123, 97, 255, 236, 108, 127, 225, 251
10014 DATA 98, 252, 254, 160



