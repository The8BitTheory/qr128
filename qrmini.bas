#RetroDevStudio.MetaData.BASIC:7169,BASIC V7.0,uppercase,10,10
1 GRAPHIC1:GRAPHIC0:GRAPHIC5
5 BANK 15:BLOAD"QR.BIN",B0
#10 T$="HTTPS://WWW.FORUM64.DE/INDEX.PHP?THREAD/141120-HALLOWEEN-LEVTY-SPEZIAL-GRUSELSCHOCKER-TURNIER/"
10 T$="HTTPS://WWW.FORUM64.DE/"
20 I=POINTER(T$)
30 BANK1:P1=PEEK(I+1):P2=PEEK(I+2):P=PEEK(I):BANK15

35 PRINT "CALLING QR-CODE GENERATION...";
40 S=TI:SYS DEC("1300"),P,P1,P2:S=TI-S

120 PRINT "TOOK "S" JIFFIES"

150 BANK0:F=PEEK(1000)+PEEK(1001)*256:L=PEEK(1002)
160 PRINT "START OF MATRIX="F"/"HEX$(F)", L="L
162 PRINT "XORING WITH PATTERN IN BIT 1"
170 O=F:C=0:R=0:GRAPHIC0:COLOR5,1:COLOR0,2:COLOR4,2:PRINT""CHR$(27)"M";:PRINT " ";

200 IF L<=25 THEN 1000
210 GOTO 6000

######
# PRINT FULL MODULES
#########
# MV:MASK-VALUE (2 MEANS BIT 1, BECAUSE 2BIT)
# DV:DATA-VALUE
# XV:XMASK-VALUE
# DV AND XV ARE XORED

1000 MV=2
1005 FOR Y=1 TO L
1010  FOR X=1 TO L

1020   PO=PEEK(O)
1021   DV=ABS((PO AND 1)=1)
1022   XV=ABS((PO AND MV)=MV)
1023   V=XOR(DV,XV)

1030   IF V=1 THEN PRINT CHR$(18)" "CHR$(146);:ELSE PRINT " ";

1040   O=O+1
1050   IF X = L THEN PRINT" ":PRINT" ";

1060  NEXT
1070 NEXT

1080 GRAPHIC5



1090 END



######
# PRINT 4 MODULES PER CHARACTER
########



6000 SLOW:REM OUTPUT MATRIX TO SCREEN
6103 DIM CH$(15)
6104 CH$(0)=CHR$(32):CH$(1)=CHR$(190):CH$(2)=CHR$(188):CH$(3)=CHR$(18)+CHR$(162)+CHR$(146)
6105 CH$(4)=CHR$(187):CH$(5)=CHR$(161):CH$(6)=CHR$(18)+CHR$(191)+CHR$(146):CH$(7)=CHR$(18)+CHR$(172)+CHR$(146)
6106 CH$(8)=CHR$(172):CH$(9)=CHR$(191):CH$(10)=CHR$(18)+CHR$(161)+CHR$(146):CH$(11)=CHR$(18)+CHR$(187)+CHR$(146)
6107 CH$(12)=CHR$(162):CH$(13)=CHR$(18)+CHR$(188)+CHR$(146):CH$(14)=CHR$(18)+CHR$(190)+CHR$(146):CH$(15)=CHR$(18)+CHR$(32)+CHR$(146)



#6110 GOTO 6300
# R:ROW
# C:COL
# O:OFFSET
# F:START OF MATRIX
# G:END OF MATRIX
# RENDERING OPTIONS
# - SHOW ADMINISTRATIVE PATTERNS AND DATASTREAM (NO XORING): 0
# - SHOW XOR WITH EVERY MASK (4) : 1-4
# - SHOW MASKS INDIVIDUALLY (4) : A-D



6221 DEF FN PA(ZZ)=((PO AND ZZ)=ZZ)

6222 DO WHILE R<(L-1)/2

6228  FT=4

6229  PO=PEEK(O)
6230  IF ((PO AND 64)=64) THEN V1=XOR(POAND1,ABS((PO AND FT)=FT)):ELSE V1=POAND1

6231  PO=PEEK(O+1)
6232  IF ((PO AND 64)=64) THEN V2=XOR(POAND1,ABS((PO AND FT)=FT)):ELSE V2=POAND1

6233  PO=PEEK(O+L)
6234  IF ((PO AND 64)=64) THEN V3=XOR(POAND1,ABS((PO AND FT)=FT)):ELSE V3=POAND1

6235  PO=PEEK(O+1+L)
6236  IF ((PO AND 64)=64) THEN V4=XOR(POAND1,ABS((PO AND FT)=FT)):ELSE V4=POAND1

6240  IF C<L-1 THEN V=V1+V2*2+V3*4+V4*8:ELSE V=V1+V3*4

6250  PRINT CH$(V);
6260  O=O+2
6265  C=C+2:IF C >= L THEN O=O+L-1:C=0:R=R+1:PRINT" ":PRINT" ";
6270 LOOP

# LAST ROW IS HANDLED INDIVIDUALLY
6271 FOR Y=0TO(L-1)/2

6273  PO=PEEK(O)
6274  IF ((PO AND 64)=64) THEN V1=XOR(POAND1,ABS((PO AND FT)=FT)):ELSE V1=POAND1

6275  PO=PEEK(O+1)
6276  IF ((PO AND 64)=64) THEN V2=XOR(POAND1,ABS((PO AND FT)=FT)):ELSE V2=POAND1

6277  IF C<L-1 THEN V=V1+V2*2:ELSE V=V1
6279  PRINT CH$(V);
6281  O=O+2:C=C+2
6283 NEXT
6285 PRINT " "

6290 PRINT:GRAPHIC5

6300 INPUT "WHICH AND VALUE TO PRINT";I$
6305 IF I$="X" THEN 6400
6310 PB=VAL(I$)
6320 GOTO 6170


6400 BANK15