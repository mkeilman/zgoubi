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
      SUBROUTINE RFIT
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     ***************************************
C     READS DATA FOR FIT PROCEDURE WITH 'FIT'
C     ***************************************
      COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      PARAMETER (MXV=40) 
      COMMON/MIMA/ DX(MXV)
      INCLUDE 'MXLD.H'
      COMMON/DON/ A(MXL,MXD),IQ(MXL),IP(MXL),NB,NOEL
      COMMON/VARY/NV,IR(MXV),NC,I1(MXV),I2(MXV),V(MXV),IS(MXV),W(MXV),
     >IC(MXV),I3(MXV),XCOU(MXV),CPAR(MXV,7)

      READ(NDAT,*) NV
      IF(NV.LT.1) RETURN
      DO 3 I=1,NV
 3      READ(NDAT,*) IR(I),IS(I),XCOU(I),DX(I)

      READ(NDAT,*) NC
      IF(NC.LT.1) RETURN
      DO 4 I=1,NC
C         READ(NDAT,*)          IC(I),I1(I),I2(I),I3(I),V(I),W(I)
        READ(NDAT,*,ERR=41,END=41) XC,I1(I),I2(I),I3(I),V(I),W(I),
     >  CPAR(I,1),(CPAR(I,JJ),JJ=2,NINT(CPAR(I,1))+1)
 41     CONTINUE
        IC(I) = INT(XC)
        IC2 = NINT(10.D0*XC - 10*IC(I))
        TST = FFI(IC2,I)
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
      END