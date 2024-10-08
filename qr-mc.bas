#RetroDevStudio.MetaData.BASIC:7169,BASIC V7.0,uppercase,10,10
10 REM GENERATES A QR CODE
# SETUP MATRIX WITH ALL VALUES TO 128
# %1....... MEANS, THE MODULE SPOT IS UNTOUCHED. CAN BE USED FOR WRITING
# %0....... MEANS, THE MODULE SPOT IS ALREADY WRITTEN. DON'T CHANGE
# %.1...... MEANS, IF WRITTEN: THE MODULE SPOT IS A CONTENT-DATA SPOT
# %.0...... MEANS, IF WRITTEN: THE MODULE SPOT IS A FINDER OR ALIGNMENT OR TIMING SPOT
# %.......1 MEANS THIS IS A DARK MODULE.
# %.......0 MEANS THIS IS A LIGHT MODULE.
# WRITE FINDER PATTERNS AND ALIGNMENT AND TIMING PATTERN. (VALUES 0 AND 1)
# ASSEMBLE BYTE-MODE (4 BITS), CONTENT-LENGTH (8 BITS), CONTENT (VARIABLE LENGTH) AND TERMINATOR BITS (4) INTO DATASTREAM
# APPEND PADDING MODULES TO DATASTREAM (108-2-CONTENT LENGTH) WITH VALUES 0XEC, 0X11
# CALCULATE ECCBYTES FROM DATASTREAM
# APPEND ECCBYTES TO DATASTREAM
# WRITE DATASTREAM INTO MATRIX
# GENERATE XOR MASK
# APPLY XOR MASK TO CONTENT-DATA MODULES

# ML CODE START AT $1300 (4864) (MAX SIZE 7424)
# BASIC START AT $4003 (16387) - END OF OUR MEMORY AREA
# DATASTREAM AT $3AAA (15018) (MAX SIZE 1369)
# MODULE-MATRIX (F) STARTS AT $3034 (12340) (MAX SIZE 2677)
# REED-SOLOMON DIVISORS AT $3000 (12288) (MAX SIZE 52)

20 FAST:GRAPHIC1:GRAPHIC5:PRINT CHR$(14)

# DATASTREAM
22 S=15018
23 T$="HTTPS://WWW.DYNATRACE.COM/":
24 GOSUB 12300:T$=T2$:PRINT T$:I=POINTER(T$)
25 BANK1:A=PEEK(I+1)+PEEK(I+2)*256:I=PEEK(I):BANK15

# DIVISORS
30 D=12288:E=D+26:F=E+26:BANK0
31 POKE D,246:POKE D+1,51:POKE D+2,183:POKE D+3,4:POKED+4,136:POKED+5,98
32 POKE D+6,199:POKE D+7,152:POKED+8,77:POKE D+9,56:POKE D+10,206:POKE D+11,24
33 POKE D+12,145:POKE D+13,40:POKE D+14,209:POKE D+15,117:POKE D+16,233
34 POKE D+17,42:POKE D+18,135:POKE D+19,68:POKE D+20,70:POKE D+21,144
35 POKE D+22,146:POKE D+23,77:POKE D+24,43:POKED+25,94

40 PRINT "DATASTREAM S:"S"/"HEX$(S)
42 PRINT "DIVISORS D:"D"/"HEX$(D)
44 PRINT "RS-RESULT E:"E"/"HEX$(E)
46 PRINT "CONTENT-LEN I:"I
48 PRINT "CONTENT AT A:"A"/"HEX$(A)
49 T=TI

# WRITE MODE NYBBLE
100 POKE S,64
# WRITE LENGTH BYTE TO STREAM
110 V=I:GOSUB 10000

# WRITE CONTENT BYTES TO STREAM
120 FOR O=0 TO I-1
130  BANK1:V=PEEK(A+O):BANK0:GOSUB 10000
140 NEXT

# THIS LEAVES THE LAST NYBBLE OF THE LAST BYTE AS-IS
150 S=S+1

# WRITE PADDING TO STREAM
200 X=108-I-2

210 POKE S,236
220 S=S+1
230 POKE S,17
240 S=S+1

250 X=X-2
260 IF X>0 GOTO 210

270 PRINT "DATASTREAM SHOULD BE COMPLETE NOW"


# CLEAN RESULT AREA
280 FOR Y=0 TO 25:POKE E+Y,0:NEXT
290 U=S:J=S-15018
295 PRINT "LENGTH OF DATASTREAM:"J
299 GOTO 481

# RS-REMAINDER FUNCTION
300 FOR O=0 TO J-1
310  X=PEEK(15018+O):PRINT "B="X;
320  Z=PEEK(E):PRINT ",RESULT[0]="Z;
330  X=XOR(X,Z):PRINT ",B XOR RESULT[0]="X
#340  X=X AND 255:PRINT"X="X

# REMOVE FIRST ELEMENT FROM RESULT-ARRAY AND ADD A TRAILING ZERO
350  FOR Y=0 TO 24
360   Z=PEEK(E+Y+1)
370   POKE E+Y,Z
380  NEXT

390  POKE E+25,0

#    RSMULTIPLY OVER RESULT
400  FOR W=0 TO 25
410   Y=PEEK(D+W)
#420   Y=Y AND 255

#     X=FACTOR, Y=DIVISOR, R=RESULT OF MULTIPLY
430   GOSUB 11000

440   Y=PEEK(E+W)
450   Y=XOR(Y,R)
460   POKE E+W,Y

470  NEXT

#475  PRINT "O";

480 NEXT

481 POKE E,59:POKE E+1,14:POKE E+2,219:POKE E+3,136:POKE E+4,19:POKE E+5,3
482 POKE E+6,18:POKE E+7,117:POKE E+8,245:POKE E+9,124:POKE E+10,58
483 POKE E+11,251:POKE E+12,222:POKE E+13,70:POKE E+14,227:POKE E+15,223
484 POKE E+16,221:POKE E+17,62:POKE E+18,243:POKE E+19,19:POKE E+20,134
485 POKE E+21,231:POKE E+22,138:POKE E+23,197:POKE E+24,119:POKE E+25,247

490 PRINT "ECC BYTES:";:FOR W=0TO25:PRINT PEEK(E+W)" ";:NEXT

# WRITE ECC BYTES INTO STREAM
500 FOR Y=0 TO 25
510  V=PEEK(E+Y)
520  POKE S,V
530  S=S+1
540 NEXT

# NEW VARIABLE-SETUP FOR WRITING MODULE MATRIX
# ONLY S IS STILL NEEDED
# W:WRITE INDEX IN MODULE-MATRIX
# L:LENGTH OF MATRIX-AXIS (17 FOR VERSION 5)
# C:CURRENT COLUMN WHEN WRITING MODULE TO MATRIX
# D:DIRECTION UP. -1=YES, 0=NO
# G:MATRIX END ADDRESS

550 L=37:W=F+L*L-1:G=W:C=L-1:D=-1

551 FOR O=F TO G
552  POKE O,128
553 NEXT

# WRITE FORMAT, TIMING, FINDER, ALIGNMENT PATTERNS
555 PRINT "WRITING FORMAT, TIMING, FINDER, ALIGNMENT PATTERNS"
560 GOSUB 2000
562 GOSUB 3000
564 GOSUB 4000
566 GOSUB 5000


# WRITE STREAM TO MODULES
600 S=15018:J=U-S

604 PRINT "MATRIX STARTS AT "F"/$"HEX$(F)
605 PRINT "MATRIX ENDS AT "G"/$"HEX$(G)
606 PRINT "WRITEIDX "(W-F)

610 FOR O=0 TO J-1
620  V=PEEK(S+O)

630  IF C<0 THEN PRINT "COL LOWER THAN ZERO. DO NOTHING.":GOTO 680

631  IF (V AND 128) = 128 THEN POKE W,65:GOTO 633
632  POKE W,64
633  GOSUB 700

634  IF (V AND  64) =  64 THEN POKE W,65:GOTO 636
635  POKE W,64
636  GOSUB 700

637  IF (V AND  32) =  32 THEN POKE W,65:GOTO 639
638  POKE W,64
639  GOSUB 700

640  IF (V AND  16) =  16 THEN POKE W,65:GOTO 642
641  POKE W,64
642  GOSUB 700

643  IF (V AND   8) =   8 THEN POKE W,65:GOTO 645
644  POKE W,64
645  GOSUB 700

646  IF (V AND   4) =   4 THEN POKE W,65:GOTO 648
647  POKE W,64
648  GOSUB 700

649  IF (V AND   2) =   2 THEN POKE W,65:GOTO 651
650  POKE W,64
651  GOSUB 700

652  IF (V AND   1) =   1 THEN POKE W,65:GOTO 654
653  POKE W,64
654  GOSUB 700


670 NEXT
671 PRINT "TOOK "TI-T" JIFFIES"

674 PRINT "MATRIX STARTS AT "F"/$"HEX$(F)
675 PRINT "MATRIX ENDS AT "G"/$"HEX$(G)

680 GOTO 1099


# ADVWRITEIDX
700 PRINT "W="(W-F)",V="V",C="C",D="D
705 IF C>6 THEN GOTO 750
710 IF C<6 THEN GOTO 800
720 GOTO 800

750 IF (C AND 1) = 1 THEN GOTO 900
760 IF (C AND 1) = 0 THEN GOTO 850

800 IF (C AND 1) = 1 THEN GOTO 850
810 IF (C AND 1) = 0 THEN GOTO 900

820 RETURN



# ADVWRITEIDX1
850 W=W-1:C=C-1
860 Z=PEEK(W)
#   MODULE OCCUPIED. MOVE TO NEXT WRITE POSITION
870 IF (Z AND 128) <> 128 THEN PRINT "W="(W-F)",Z="Z" -> ADVWRITEIDX2":GOTO 900
879 RETURN

# ADVWRITEIDX2
#   CURRENTLY GOING UP (D = DIR-UP)?
900 IF D THEN 915

#   NOT DIR-UP
910 GOTO 930

#   MOVING UP
915 W=W-L+1
920 IF W<F THEN W=W+L-2:D=0:C=C-2:PRINT "  NOW DOWN. C="(C+1)
925 GOTO 950

#   MOVING DOWN
930 W=W+L+1
940 IF W>G THEN W=W-L-2:D=-1:C=C-2:PRINT "  NOW UP. C="(C+1)

950 C=C+1:REM PRINT "C="C

960 Z=PEEK(W)
970 IF (Z AND 128) <> 128 THEN PRINT "W="(W-F)",Z="Z" -> ADVWRITEIDX1":GOTO 850
980 RETURN



#999 T=TI
#1000 FOR Z=2 TO 25
#1005  X=PEEK(D+Z)
#1010  FOR Y=2 TO 8
#1015   GOSUB 11000
#1020   PRINT "X="X",Y="Y",R="R
#1030  NEXT
#1040 NEXT

#1050 PRINT TI-T
1099 END

# WRITE FORMAT INFO
#    TOP-LEFT
2000 POKE F+8*L  ,1
2002 POKE F+8*L+1,1
2004 POKE F+8*L+2,1
2006 POKE F+8*L+3,0
2008 POKE F+8*L+4,1
2010 POKE F+8*L+5,1
2012 POKE F+8*L+6,1
2014 POKE F+8*L+7,1

2016 POKE F+8,0
2018 POKE F+8+L  ,0
2020 POKE F+8+L*2,1
2022 POKE F+8+L*3,0
2024 POKE F+8+L*4,0
2026 POKE F+8+L*5,0
2028 POKE F+8+L*6,0
2030 POKE F+8+L*7,1

#    TOP-RIGHT
2032 POKE F+29+8*L,1
2034 POKE F+30+8*L,1
2036 POKE F+31+8*L,0
2038 POKE F+32+8*L,0
2040 POKE F+33+8*L,0
2042 POKE F+34+8*L,1
2044 POKE F+35+8*L,0
2046 POKE F+36+8*L,0

#    BOTTOM-LEFT
2048 POKE F+8+29*L,1
2050 POKE F+8+30*L,1
2052 POKE F+8+31*L,1
2054 POKE F+8+32*L,1
2056 POKE F+8+33*L,0
2058 POKE F+8+34*L,1
2060 POKE F+8+35*L,1
2062 POKE F+8+36*L,1



2999 RETURN

# WRITE TIMING PATTERNS
#    HORIZONTAL
3000 O=L*6
3010 FOR X=0 TO (L-1)/2
3020  POKE F+O,1
3025  O=O+1
3030  POKE F+O,0
3035  O=O+1
3040 NEXT
3050 POKE F+O,1


#    VERTICAL
3100 O=6
3110 FOR X=0 TO (L-1)/2
3120  POKE F+O,1
3125  O=O+L
3130  POKE F+O,0
3135  O=O+L
3140 NEXT
3150 POKE F+O,1

3999 RETURN

# WRITE FINDER PATTERNS
#    TOP-LEFT
4000 O=0:GOSUB 4900
4010 O=7:GOSUB 4950
4020 O=8:GOSUB 4950

4030 O=7*L:GOSUB 4960
4040 O=8*L:GOSUB 4960

4050 POKE F+8+6*L,1
4060 POKE F+6+8*L,1
4070 POKE F+8+8*L,0


#    TOP-RIGHT
4100 O=30:GOSUB 4900
4110 O=29:GOSUB 4950
4120 O=29+7*L:GOSUB 4960
4130 O=29+8*L:GOSUB 4960


#    BOTTOM-LEFT
4200 O=30*L:GOSUB 4900
4210 O=29*L:GOSUB 4960
4220 O=7+29*L:GOSUB 4950
4230 O=8+29*L:GOSUB 4950
4240 POKE F+8+29*L,1


4899 RETURN

# WRITE FINDER PATTERN
4900 POKE F+O,1:O=O+1
4901 POKE F+O,1:O=O+1
4902 POKE F+O,1:O=O+1
4903 POKE F+O,1:O=O+1
4904 POKE F+O,1:O=O+1
4905 POKE F+O,1:O=O+1
4906 POKE F+O,1:O=O+1

4910 O=O+L-7
4911 POKE F+O,1:O=O+1
4912 POKE F+O,0:O=O+1
4913 POKE F+O,0:O=O+1
4914 POKE F+O,0:O=O+1
4915 POKE F+O,0:O=O+1
4916 POKE F+O,0:O=O+1
4917 POKE F+O,1:O=O+1

4919 Z=0:DO
4920  O=O+L-7
4921  POKE F+O,1:O=O+1
4922  POKE F+O,0:O=O+1
4923  POKE F+O,1:O=O+1
4924  POKE F+O,1:O=O+1
4925  POKE F+O,1:O=O+1
4926  POKE F+O,0:O=O+1
4927  POKE F+O,1:O=O+1
4928  Z=Z+1
4929 LOOP WHILE Z<3

4930 O=O+L-7
4931 POKE F+O,1:O=O+1
4932 POKE F+O,0:O=O+1
4933 POKE F+O,0:O=O+1
4934 POKE F+O,0:O=O+1
4935 POKE F+O,0:O=O+1
4936 POKE F+O,0:O=O+1
4937 POKE F+O,1:O=O+1

4940 O=O+L-7
4941 POKE F+O,1:O=O+1
4942 POKE F+O,1:O=O+1
4943 POKE F+O,1:O=O+1
4944 POKE F+O,1:O=O+1
4945 POKE F+O,1:O=O+1
4946 POKE F+O,1:O=O+1
4947 POKE F+O,1:O=O+1

4949 RETURN

# WRITE 8 VERTICAL ZEROES
4950 FOR Z=0 TO 7
4951  POKE F+O,0:O=O+L
4952 NEXT
4954 RETURN

# WRITE 8 HORIZONTAL ZEROES
4960 FOR Z=0 TO 7
4961  POKE F+O,0:O=O+1
4962 NEXT
4964 RETURN


# WRITE ALIGNMENT PATTERNS
5000 O=28+28*L

5010 POKE F+O,1:O=O+1
5011 POKE F+O,1:O=O+1
5012 POKE F+O,1:O=O+1
5013 POKE F+O,1:O=O+1
5014 POKE F+O,1:O=O+1

5020 O=O+L-5
5021 POKE F+O,1:O=O+1
5022 POKE F+O,0:O=O+1
5023 POKE F+O,0:O=O+1
5024 POKE F+O,0:O=O+1
5025 POKE F+O,1:O=O+1

5030 O=O+L-5
5031 POKE F+O,1:O=O+1
5032 POKE F+O,0:O=O+1
5033 POKE F+O,1:O=O+1
5034 POKE F+O,0:O=O+1
5035 POKE F+O,1:O=O+1

5040 O=O+L-5
5041 POKE F+O,1:O=O+1
5042 POKE F+O,0:O=O+1
5043 POKE F+O,0:O=O+1
5044 POKE F+O,0:O=O+1
5045 POKE F+O,1:O=O+1

5050 O=O+L-5
5051 POKE F+O,1:O=O+1
5052 POKE F+O,1:O=O+1
5053 POKE F+O,1:O=O+1
5054 POKE F+O,1:O=O+1
5055 POKE F+O,1:O=O+1

5999 RETURN


# WRITE BYTE TO STREAM
#10000 PRINT "V="HEX$(V)",";
10000 Z=INT(V/2/2/2/2)
10010 Y=PEEK(S)
10015 Y=Y OR Z
10020 POKE S,Y
#10025 PRINT "BYTE 1="HEX$(Y)",";

10030 S=S+1
10040 Z=Z*16
10050 Z=V-Z
10060 Z=Z*2*2*2*2
10065 Z=Z AND 255
10070 POKE S,Z
#10075 PRINT "BYTE2="HEX$(Z)

10080 RETURN


# RSMULTIPLY
11000 R=0
11001 IF X=0 THEN 11999
11002 IF Y=0 THEN 11999
11003 IF X=1 THEN R=Y:GOTO 11999
11004 IF Y=1 THEN R=X:GOTO 11999

11005 FOR J=7 TO 0 STEP -1
11010  B=R*2
11015  B=B AND 255
#:PRINT " B"B

11020  C=INT(R/128)
11030  C=C*285
11040  R=XOR(B,C)
#:PRINT " R"R

11045  C=2J
#:PRINT " C"C
11050  B=INT(Y/C)
11060  B=B AND 1
11070  B=B*X

11080  R=XOR(R,B) AND 255
#:PRINT "R"R:PRINT

11090 NEXT

11999 RETURN

# CONVERT FROM PETSCII TO ASCII
12300 T2$=""
12305 FOR X=1 TO LEN(T$)
12310  C$=MID$(T$,X,1):A=ASC(C$)
12320  IF A>=193 AND A<=218 THEN A=A-128:T2$=T2$+CHR$(A):GOTO 12340
12325  IF A>=65 AND A<=90 THEN A=A+32:T2$=T2$+CHR$(A):GOTO 12340
12330  T2$=T2$+C$
12340 NEXT

12399 RETURN
