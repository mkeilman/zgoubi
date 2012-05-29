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
C  Brookhaven National Laboratory                    �s
C  C-AD, Bldg 911
C  Upton, NY, 11973
C  USA
C  -------
      SUBROUTINE RFIT(PNLTY)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     ***************************************
C     READS DATA FOR FIT PROCEDURE WITH 'FIT'
C     ***************************************
      COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      PARAMETER (MXV=40) 
      COMMON/MIMA/ DX(MXV),XMI(MXV),XMA(MXV)
      INCLUDE 'MXLD.H'
      COMMON/DON/ A(MXL,MXD),IQ(MXL),IP(MXL),NB,NOEL
      COMMON/VARY/NV,IR(MXV),NC,I1(MXV),I2(MXV),V(MXV),IS(MXV),W(MXV),
     >IC(MXV),IC2(MXV),I3(MXV),XCOU(MXV),CPAR(MXV,7)

      CHARACTER TXT132*132
      LOGICAL STRCON, CMMNT

      READ(NDAT,*) NV
      IF(NV.LT.1) RETURN

      DO I=1,NV
        READ(NDAT,FMT='(A)') TXT132
        CMMNT = STRCON(TXT132,'!',
     >                            III) 
        IF(CMMNT) THEN
          III = III - 1
        ELSE
          III = 132
        ENDIF
        IF(STRCON(TXT132(1:III),'[',
     >                              II)) THEN
C--------- New method
          READ(TXT132(1:II-1),*) IR(I),IS(I),XCOU(I)
          IF(STRCON(TXT132,']',
     >                      II2)) THEN
            READ(TXT132(II+1:II2-1),*) XMI(I),XMA(I)
          ELSE
            CALL ENDJOB(' SBR RFIT, wrong input data / variables',-99)
          ENDIF
        ELSE
C--------- Old method
 
           READ(TXT132,*) IR(I),IS(I),XCOU(I),DX(I)
           XI = A(IR(I),IS(I))
           XMI(I)=XI-ABS(XI)*DX(I)
           XMA(I)=XI+ABS(XI)*DX(I)

        ENDIF
      ENDDO

C      READ(NDAT,*) NC
      READ(NDAT,FMT='(A)') TXT132
      READ(txt132,*,err=44,end=44) NC, pnlty
      goto 45
 44   continue
      READ(txt132,*,err=98,end=98) NC    
      pnlty = -1.d10
 45   continue

      IF(NC.LT.1) RETURN
      DO 4 I=1,NC
        READ(NDAT,*,ERR=41,END=41) XC,I1(I),I2(I),I3(I),V(I),W(I),
     >  CPAR(I,1),(CPAR(I,JJ),JJ=2,NINT(CPAR(I,1))+1)
 41     CONTINUE
        IC(I) = INT(XC)
        IC2(I) = NINT(10.D0*XC - 10*IC(I))
 4    CONTINUE  

C----- Looks for possible parameters, with values in CPAR, and action
      DO 5 I=1,NC
        IF    (IC(I).EQ.3) THEN 
C--------- Traj coord
          IF(I1(I).EQ.-3)  THEN
            CALL DIST2W(CPAR(I,2), CPAR(I,3), CPAR(I,4))
          ENDIF
        ELSEIF(IC(I).EQ.5) THEN 
C--------- Numb. particls
          IF(I1(I).GE.1) THEN
            IF(I1(I).LE.3) THEN
              CALL ACCENW(CPAR(I,2))
            ELSEIF(I1(I).LE.6) THEN
              CALL ACCEPW(CPAR(I,2))
            ENDIF
          ENDIF
        ENDIF
 5    CONTINUE  

      RETURN

 98   CALL ENDJOB('SBR rfit, error input data after NV',-99)
      RETURN
      END
