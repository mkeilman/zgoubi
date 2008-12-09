C  ZGOUBI, a program for computing the trajectories of charged particles
C  in electric and magnetic fields
C  Copyright (C) 1988-2007  Fran�ois M�ot
C
C  This program is free software; you can redistribute it and/or modify
C  it under the terms of the GNU General Public License as published by
C  the Free Software Foundation; either version 2 of the License, or
C  (at your option) any later version.
C
C  This program is distributed in the hope that it will be useful,
C  but WITHOUT ANY WARRANTY; without even the implied warranty of
C  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
C  GNU General Public License for more details.
C
C  You should have received a copy of the GNU General Public License
C  along with this program; if not, write to the Free Software
C  Foundation, Inc., 51 Franklin Street, Fifth Floor,
C  Boston, MA  02110-1301  USA
C
C  Fran�ois M�ot <meot@lpsc.in2p3.fr>
C  Service Acc�lerateurs
C  LPSC Grenoble
C  53 Avenue des Martyrs
C  38026 Grenoble Cedex
C  France
      SUBROUTINE POLMES(SCAL,KUASEX,
     >                          BMIN,BMAX,BNORM,
     >                          XBMI,YBMI,ZBMI,XBMA,YBMA,ZBMA)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'PARIZ.H'
      COMMON//XA(MXX),RO(MXY),ZH(IZ),HC(ID,MXX,MXY,IZ),IAMA,JRMA,KZMA
      COMMON/AIM/ ATO,AT,ATOS,RM,XI,XF,EN,EB1,EB2,EG1,EG2
      COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
C      INCLUDE "MAXTRA.H"
C      COMMON/CHAMBR/ LIMIT,IFORM,YLIM2,ZLIM2,SORT(MXT),FMAG,BMAX
C     > ,YCH,ZCH
      COMMON/CONST/ CL9,CL ,PI,RAD,DEG,QE ,AMPROT, CM2M
      INCLUDE 'MXLD.H'
      COMMON/DON/ A(MXL,MXD),IQ(MXL),IP(MXL),NB,NOEL
      CHARACTER*80 TA
      COMMON/DONT/ TA(MXL,20)
      COMMON/DROITE/ AM(9),BM(9),CM(9),IDRT
      COMMON/INTEG/ PAS,DXI,XLIM,XCE,YCE,ALE,XCS,YCS,ALS,KP
      LOGICAL ZSYM
      COMMON/OPTION/ KFLD,MG,LC,ML,ZSYM
      COMMON/ORDRES/ KORD,IRD,IDS,IDB,IDE,IDZ

      LOGICAL BINAR,BINARI,IDLUNI, NEWFIC
      CHARACTER TITL*80 , NOMFIC(IZ)*80, NAMFIC*80
      DATA NOMFIC / IZ*'               '/ 
      SAVE NOMFIC, NAMFIC
      DATA NEWFIC / .TRUE. /

C      DIMENSION CBM(MXX)
      INTEGER DEBSTR,FINSTR

C      DATA ACN / 0.D0 /

      IF(KUASEX .EQ. 22) NDIM=2

      BNORM = A(NOEL,10)*SCAL
      TITL = TA(NOEL,1)
      IAMA = A(NOEL,20)
      IF(IAMA.GT.MXX) 
     >   CALL ENDJOB('X-dim of map is too large, max is ',MXX)
      JRMA = A(NOEL,21)
      IF(JRMA.GT.MXY ) 
     >   CALL ENDJOB('Y-dim of map is too large, max is ',MXY)

      IF(NDIM .EQ. 3) THEN
        KZMA =A(NOEL,22)
        IF(KZMA.GT.IZ ) 
     >   CALL ENDJOB('Z-dim of map is too large, max is ',IZ)
      ENDIF

      IF    (NDIM.LE.2 ) THEN
        NFIC=1
        NAMFIC = TA(NOEL,2)
        NAMFIC = NAMFIC(DEBSTR(NAMFIC):FINSTR(NAMFIC))
        NEWFIC = NAMFIC .NE. NOMFIC(NFIC)
        NOMFIC(NFIC) = NAMFIC(DEBSTR(NAMFIC):FINSTR(NAMFIC))             
      ELSEIF(NDIM .EQ. 3 ) THEN
        MOD = NINT(A(NOEL,23))
        IF    (MOD .EQ. 0) THEN
C         ... 3-D map will be symmetrized wrt horizontal plane using SYMMED
          I1 = (KZMA/2) + 1
        ELSEIF(MOD .EQ. 1) THEN
C         ... No symm 
          I1 = 1
          ZSYM=.FALSE.
        ENDIF
        NFIC=0
        NEWFIC = .TRUE.
        DO 129 I=I1,KZMA
          NFIC = NFIC+1
          NAMFIC = TA(NOEL,1+NFIC)
          NEWFIC = NEWFIC .AND. (NAMFIC .NE. NOMFIC(NFIC))          
          NOMFIC(NFIC) = NAMFIC(DEBSTR(NAMFIC):FINSTR(NAMFIC))
 129    CONTINUE
      ENDIF

      IF(NRES.GT.0) THEN
        IF(NEWFIC) THEN
           WRITE(NRES,209) 
 209       FORMAT(/,10X,' A new field map is now used ; ', 
     >     ' Name(s) of map data file(s) are : ')
           WRITE(6   ,208) (NOMFIC(I),I=1,NFIC)
           WRITE(NRES,208) (NOMFIC(I),I=1,NFIC)
 208       FORMAT(10X,A)
        ELSE
          WRITE(NRES,210) (NOMFIC(I),I=1,NFIC)
 210      FORMAT(
     >    10X,'No  new  map  file  to  be  opened. Already  stored.',/
     >    10X,'Skip  reading  field  map  file : ',10X,A80)
        ENDIF
      ENDIF
 
      IF(KUASEX .EQ. 22 ) THEN
C------ POLARMES
C------ CARTE POLAIRE 2-D 

        IF(NEWFIC) THEN
          IF(IDLUNI(
     >              LUN)) THEN
            BINAR=BINARI(NOMFIC(NFIC),IB)
            IF(BINAR) THEN
              OPEN(UNIT=LUN,FILE=NOMFIC(NFIC),FORM='UNFORMATTED'
     >        ,STATUS='OLD',ERR=96)
            ELSE
              OPEN(UNIT=LUN,FILE=NOMFIC(NFIC),STATUS='OLD',ERR=96)
           ENDIF
          ELSE
            GOTO 96
          ENDIF

          BMIN =  1.D10
          BMAX = -1.D10
          IRD = NINT(A(NOEL,40))
 
          CALL FMAPR(BINAR,LUN,
     >                         RM)
  
          DO 222 J=1,JRMA
            DO  222  I = 1,IAMA
              BFLD = HC(ID,I,J,1)
              IF    (BFLD .GT. BMAX) THEN
                BMAX = BFLD
                XBMA = XA(I)
                YBMA = RO(J)
              ELSEIF(BFLD .LT. BMIN) THEN
                BMIN = BFLD
                XBMI = XA(I)
                YBMI = RO(J)
              ENDIF
              HC(ID,I,J,1) = BFLD * BNORM
 222      CONTINUE
        ENDIF

      ENDIF
C----- KUASEX

      CALL MAPLI1(BMAX-BMIN)

      AT=XA(IAMA)-XA(1)
      ATO = 0D0
      ATOS = 0D0
C      RM=.5D0*(RO(JRMA)+RO(1))

      XI = XA(1)
      XF = XA(IAMA)
 
15    CONTINUE

      RETURN

 96   WRITE(NRES,*) 'ERROR  OPEN  FILE ',NOMFIC(NFIC)
      CALL ENDJOB('ERROR  OPEN  FILE ',-99)
 
      END