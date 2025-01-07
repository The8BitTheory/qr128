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

#20 BLOAD"QRM65.BIN",B0
30 H$="HTTPS://"
40 T$="GITHUB.COM"

50 T$=H$+T$

60 PRINT"GENERATING QR-CODE..."
70 S=TI:BANK0

71 FOR X=1 TO LEN(T$)
72  POKE BE+X,ASC(MID$(T$,X,1))
73 NEXT
74 LB=FNLB(BE+1):HB=FNHB(BE+1)

110 SYS SA,LEN(T$),LB,HB

120 S=TI-S
130 RREG A,X,Y:F=X+Y*256:L=A

140 PRINT ""T$:PRINT"TOOK"S"JIFFIES"
150 CURSOR 40,0,0:PRINT "MATRIX AT $"HEX$(F)", L="L
160 CURSOR 40,1,0:PRINT "1-3 CHANGE MASK"
170 CURSOR 40,2,0:PRINT "S   SAVE RUNTIME"
180 CURSOR 40,3,0:PRINT "N   NEW QR-CODE"
190 CURSOR 40,4,0:PRINT "R   RENDER WITH BASIC"
200 CURSOR 40,5,0:PRINT "X   EXIT"
210 GETKEY I$

220 IF ASC(I$)>48 THEN IF ASC(I$)<53 THEN BM=2(ASC(I$)-48):POKE (SA+7),BM:GOTO 60
230 IF I$="S" THEN 1000
240 IF I$="N" THEN 280
250 IF I$="R" THEN GOSUB 315
260 IF I$="X" THEN 310
270 GOTO 160

280 PRINT "URL TO ENCODE (WITHOUT "H$"):"
290 INPUT T$:IF T$="X" THEN END
300 GOTO 50

310 END

315 DO WHILE R<(L-1)/2
320  FT=4
325  PO=PEEK(O)
330  IF ((PO AND 64)=64) THEN V1=(POAND1)XOR(ABS((PO AND FT)=FT)):ELSE V1=POAND1
335  PO=PEEK(O+1)
340  IF ((PO AND 64)=64) THEN V2=(POAND1)XOR(ABS((PO AND FT)=FT)):ELSE V2=POAND1
345  PO=PEEK(O+L)
350  IF ((PO AND 64)=64) THEN V3=(POAND1)XOR(ABS((PO AND FT)=FT)):ELSE V3=POAND1
355  PO=PEEK(O+1+L)
360  IF ((PO AND 64)=64) THEN V4=(POAND1)XOR(ABS((PO AND FT)=FT)):ELSE V4=POAND1
365  IF C<L-1 THEN V=V1+V2*2+V3*4+V4*8:ELSE V=V1+V3*4
370  PRINT CH$(V);
375  O=O+2
380  C=C+2:IF C >= L THEN O=O+L-1:C=0:R=R+1:PRINT" ":PRINT" ";
385 LOOP

#320 FOR Y=0 TO L-1
#330  FOR X=0 TO L-1
#340   PO=PEEK(F+X+Y*L)
#350   IF (PO AND 32)=32 THEN PRINT " ";:GOTO 180
#360   PRINT " ";
#370  NEXT:PRINT
#380 NEXT
390 RETURN


# SAVE FILE
1000 PRINT "PREPARING RUNTIME...";
1010 GOSUB 9000:AS=F:AE=AS+L:PRINT "DONE"
1020 PRINT "QRCODE FROM "AS" TO "AE" ("L" BYTES LONG)"

1030 INPUT "START ADDRESS OF QR-RUNTIME";A$
1040 INPUT "FILENAME";N$
1050 VL=VAL(A$)
1060 IF VL=$C000 THEN 1200

1100 FOR X=0 TO 8
1110  V=VL+AO%(X)
1120  SC%(CO%(X))=FNLB(V):SC%(CO%(X)+1)=FNHB(V)
1130 NEXT

# SC%() = SOURCE-CODE POSITION. CONTAINS ALL BYTES OF THE RUNTIME BINARY
# CO%() = CODE-OFFSET. 
# AO%() = ADDRESS-OFFSETS.

1200 OPEN1,DD,1,N$+",P,W"

# WRITE ADDRESS-BYTES
1210 PRINT#1,CHR$(FNLB(VL));CHR$(FNHB(VL));

# WRITE QR-VIEWER RUNTIME
1220 FOR X=0 TO NV
1230  O$=CHR$(SC%(X))
1240  PRINT#1,O$;
1250  PRINT".";
1260 NEXT
1270 PRINT

# WRITE QR-CODE DATA
1280 FOR X=0 TO A:O$=CHR$(PEEK(AS+X))
1290  PRINT#1,O$;:PRINT".";
1300 NEXT
1310 PRINT
1320 CLOSE1
1330 PRINT "DONE"

1999 GOTO 150


##########################################
# BUILD BYTE ARRAY FOR GENERATING BINARY #
##########################################

9000 RESTORE
9010 FOR X=0TONV
9020  READ D
9030  SC%(X)=D
9040 NEXT

9105 CO=0
9110 FOR X=0TONV
9120  IF SC%(X)=192 THEN CO%(CO)=X-1:AO%(CO)=SC%(X-1):CO=CO+1
9140 NEXT

9250 RETURN


10000 DATA 134,253,132,254,133,252,160,0,162,0,189,100,192,232,134,251
10010 DATA 141,83,192,141,82,192,166,251,189,100,192,72,74,74,74,74
10020 DATA 32,48,192,104,176,9,41,15,32,48,192,230,251,208,231,96
10030 DATA 170,189,84,192,145,253,200,204,82,192,208,18,206,83,192,240
10040 DATA 15,165,253,24,101,252,133,253,144,2,230,254,160,0,24,96
10050 DATA 56,96,0,0,32,126

10055 DATA 124,226,123,97,255,236,108,127
10060 DATA 225,251,98,252,254,160