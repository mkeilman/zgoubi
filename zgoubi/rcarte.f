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
C  Fran�ois M�ot <fmeot@bnl.gov>
C  Brookhaven National Laboratory     
C  C-AD, Bldg 911
C  Upton, NY, 11973, USA
C  -------
      SUBROUTINE RCARTE(KART,IDIM,
     >                            ND)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     ---------------------------------------------------
C     READS B-FIELD FOR CARTEMES, TOSCA, BREVOL,
C       AND E(R=0,X)-FIELD FOR ELREVOL
C     ---------------------------------------------------
      INCLUDE "C.CDF.H"     ! COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      INCLUDE 'MXLD.H'
      INCLUDE "C.DON.H"     ! COMMON/DON/ A(MXL,MXD),IQ(MXL),IP(MXL),NB,NOEL
C      PARAMETER (LNTA=132) ; CHARACTER(LNTA) TA
C      PARAMETER (MXTA=45)
      INCLUDE "C.DONT.H"     ! COMMON/DONT/ TA(MXL,MXTA)

      CHARACTER(132) TXT
      PARAMETER (MXSTR=20)
      CHARACTER(LNTA) STRA(MXSTR)
      INTEGER DEBSTR
      LOGICAL STRCON
      LOGICAL ISNUM

C     ... IC, IL
      LINE = 1
      READ(NDAT,*) A(NOEL,1),A(NOEL,2)

CC   RUSTINE CHICANE CEBAF
CC     ... BNORM...
C      READ(NDAT,*,ERR=10) A(NOEL,10), A(NOEL,11),A(NOEL,12)
C      GOTO 11
C 10   CONTINUE
C      A(NOEL,11) = 0.D0
C      A(NOEL,12) = 0.D0
C      BACKSPACE(NDAT)
C 11   CONTINUE

C----- BNORM & X-,Y-,Z-NORM
      DO I = 1, IDIM    ! For compatibility with earlier versions
        A(NOEL,10+I) = 1.D0
      ENDDO
      LINE = LINE + 1
      READ(NDAT,FMT='(A)',ERR=97) TXT   
      IF( STRCON(TXT,'!', 
     >                   IS)) TXT = TXT(DEBSTR(TXT):IS-1)
      CALL STRGET(TXT,4,
     >                  NSTR,STRA)
      IF(NSTR .GT. MXSTR) GOTO 97
      I = 1
      DOWHILE (I .LE. NSTR)
        IF(ISNUM(STRA(I)))   ! In case unexpectedly a ! is missing at that line...
     >  READ(STRA(I),*,ERR=97) A(NOEL,9+I)
        I = I + 1
      ENDDO      
 
C----- TITLE - Start TITLE with FLIP to get map flipped (implemented with TOSCA... to 
C                       be completed for others)
      LINE = LINE + 1
      READ(NDAT,200) TA(NOEL,1)
 200  FORMAT(A)

      IF    (IDIM .EQ. 1) THEN
        LINE = LINE + 1
        READ(NDAT,*) A(NOEL,20)
        NFIC = 1
      ELSEIF(IDIM .EQ. 2) THEN
        LINE = LINE + 1
        READ(NDAT,FMT='(A)') TXT
        CALL STRGET(TXT,4,
     >                    NSTR,STRA)
        READ(STRA(1),*) NX
        READ(STRA(2),*) NY
        A(NOEL,20)=NX
        A(NOEL,21)=NY
        IF(NSTR.EQ.3) THEN 
          READ(STRA(3),*) AMOD
        ELSE
          AMOD = 0.D0
        ENDIF
        A(NOEL,22)=AMOD
        NFIC = 1

      ELSEIF(IDIM .EQ. 3) THEN
C------- TOSCA, 2-D or 3-D maps, either cartesian mesh (MOD.le.19), or polar mesh (MOD.ge.20) 
        LINE = LINE + 1
        READ(NDAT,FMT='(A)') TXT
        CALL STRGET(TXT,4,
     >                    NSTR,STRA)
        READ(STRA(1),*) NX
        READ(STRA(2),*) NY
        IF(NSTR.GE.3) THEN 
          READ(STRA(3),*) KZMA
          IF(NSTR.GE.4) THEN
            READ(STRA(4),*) AMOD
          ELSE
            AMOD = 0
          ENDIF
        ELSE
          KZMA = 1
C------- To ensure compatibility with version 3 of Zgoubi
          AMOD = 0.D0
        ENDIF

        A(NOEL,20)=NX
        A(NOEL,21)=NY
        A(NOEL,22)=KZMA
        A(NOEL,23)=AMOD
        MOD=INT(AMOD)
        MOD2 = NINT (10 *  (AMOD -  DBLE(MOD)) )
 
C--------------------------------------------------------
        IF    (MOD .LE. 19) THEN
C--------- Cartesian mesh
          KART = 1
          IF    (MOD .EQ. 0) THEN
C----------- 3-D map generated by  symmetrysing wrt horizontal plane
            NFIC = (KZMA/2) + 1
          ELSEIF(MOD .EQ. 3) THEN
C--------- AGS mid-plane 2-D maps
            NFIC = 1
            IF(MOD2.EQ.1) READ(TXT,*,ERR=99,END=99) 
     >      IDUM1,IDUM2,IDUM3,DUM4,DB1,DB2
            A(NOEL,24)=DB1
            A(NOEL,25)=DB2               
          ELSEIF(MOD .EQ.10) THEN
C----------- 3-D map generated by  symmetrysing wrt horizontal plane
            NFIC = (KZMA/2) + 1
          ELSEIF(MOD .EQ. 1) THEN
C----------- no symmetrization, 3-D map generated by taking 2-D maps as is
            NFIC = KZMA
          ELSEIF(MOD .EQ. 12) THEN
C--------- The all 3D map is contained in a single file
            NFIC = 1
          ELSEIF(MOD .EQ. 15) THEN
C--------- There are 'MOD2' files, they will be combined linearly
C          Each single file contains the all 3D volume

            NFIC = MOD2

            IF(4+NFIC .GT. MXSTR) THEN
              WRITE(ABS(NRES),*) 'At input data line ',LINE
              CALL ENDJOB('Pgm rcarte. Too many'
     >        //'  field map scaling factors. Max is ',4)
            ENDIF

            CALL STRGET(TXT,4+NFIC,
     >                           IDUM,STRA) 
            DO J = 1, NFIC
              READ(STRA(4+j),*) A(NOEL,23+J) 
            ENDDO

          ELSE
            NFIC = 1
          ENDIF

        ELSEIF(MOD .GE. 20) THEN
C--------- Cylindrical mesh. Axis is Z. The all 3D map is contained in a single file
          KART = 2
          NFIC = 1

        ENDIF
      ENDIF

C----- MAP FILE NAME(S)
      IF(NFIC.GT.1) THEN 
        DO 37 IFIC=1,NFIC
          LINE = LINE + 1
          READ(NDAT,FMT='(A)') TXT
          CALL STRGET(TXT,1,
     >                      IDUM,STRA) 
          TA(NOEL,1+IFIC) = STRA(1)
 37     CONTINUE
      ELSEIF(NFIC.EQ.1) THEN
C------- Will sum (superimpose) 1D or 2D field maps if map file name is followed by 'SUM'
        IDUM = 0
        IFIC = 1
        LINE = LINE + 1
        READ(NDAT,FMT='(A)') TXT
        IF(STRCON(TXT,'!',
     >                    IS)) TXT = TXT(DEBSTR(TXT):IS-1)
        CALL STRGET(TXT,2,
     >                    IDUM,STRA) 
        TA(NOEL,1+IFIC) = TXT
        DO WHILE(IDUM.EQ.2 .AND. STRA(2).EQ.'SUM') 
          IF(IFIC .GE. MXTA) CALL ENDJOB('Pgm rcarte. '
     >    //'Too many field maps. Max allowed is  ',MXTA-2)
          IFIC = IFIC + 1
          LINE = LINE + 1
          READ(NDAT,FMT='(A)') TXT
          IF(STRCON(TXT,'!',
     >                    IS)) TXT = TXT(DEBSTR(TXT):IS-1)
          CALL STRGET(TXT,2,
     >                      IDUM,STRA) 
          TA(NOEL,1+IFIC) = TXT
        ENDDO
      ENDIF

C----- DROITE(S) DE COUPURE (IA=-1, 1, 2 or 3)
      LINE = LINE + 1
      READ(NDAT,FMT='(A)') TXT
      READ(TXT,*) IA
      IF(IA.GE.1) READ(TXT,*) IA,(A(NOEL,I),I=31,30+3*ABS(IA))

      IF(IA .GT. 3) CALL ENDJOB(
     >  '*** Error, SBR RCARTE -> input data IDRT should be < ',4)

      A(NOEL,30) = IA
C     ... IRD
      LINE = LINE + 1
      READ(NDAT,*) A(NOEL,40)
C     ... XPAS
      LINE = LINE + 1
      READ(NDAT,*) A(NOEL,50)
      ND = 50 

      IF(KART .EQ. 1) THEN
C       ... Cartesian map frame
C           KP, XCE, YCE, ALE
        LINE = LINE + 1
        READ(NDAT,*) IA,(A(NOEL,I),I=ND+10+1,ND+10+3)
        A(NOEL,ND+10) = IA
      ELSEIF(KART .EQ. 2) THEN
C       ... Polar map frame
        LINE = LINE + 1
        READ(NDAT,*) KP
        A(NOEL,ND+10) = KP
        IF( KP .EQ. 2 ) THEN
          LINE = LINE + 1
          READ(NDAT,*) (A(NOEL,I),I=ND+20,ND+20+3)
        ELSE
          LINE = LINE + 1
          READ(NDAT,*) A(NOEL,ND+20)
        ENDIF
      ENDIF

      RETURN

 97   CONTINUE
      WRITE(NRES,*) 'SBR rcarte, normalization coefficients : '
     >//' input data error'
      CALL ENDJOB('Expected is a list of  1 to 4 data.',-99)
      STOP
 99   CONTINUE
      WRITE(NRES,*) 'SBR rcarte, input data Error'
      CALL ENDJOB('Expecting more data after MOD=3.*',-99)
      STOP
      END
