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
C  Upton, NY, 11973
C  USA
C  -------
      SUBROUTINE RCAVIT
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     **************************
C     READS DATA FOR ACC. CAVITY
C     **************************
      INCLUDE "C.CDF.H"     ! COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      INCLUDE 'MXLD.H'
      INCLUDE "C.DON.H"     ! COMMON/DON/ A(MXL,MXD),IQ(MXL),IP(MXL),NB,NOEL
      PARAMETER (MXTA=45)
      INCLUDE "C.DONT.H"     ! COMMON/DONT/ TA(MXL,MXTA)

      CHARACTER(132) TXT132
      LOGICAL STRCON
      INTEGER DEBSTR

C     ....IOPT -OPTION
C      READ(NDAT,*) A(NOEL,1)
      READ(NDAT,FMT='(A)') TXT132      
      READ(TXT132,*) A(NOEL,1)
      IF(STRCON(TXT132,'!',
     >                     IS)) TXT132 = TXT132(DEBSTR(TXT132):IS-1)
      IF(STRCON(TXT132,'PRINT',
     >                         IS) 
     >   .OR.  (NINT(10.D0*A(NOEL,1)) - 10*INT(A(NOEL,1))).EQ.1) THEN
        TA(NOEL,1) = 'PRINT'        
      ELSE
        TA(NOEL,1) = '    '
      ENDIF

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC     ....FREQ. (Hz), H -HARMONIQUE
C     ....Orbit length. (m), H -HARMONIQUE
      READ(NDAT,*) A(NOEL,10),A(NOEL,11)
C     ....V(Volts), PHS(rd)  :  dW = q*V sin( H*OMEGA*T + PHS)
      READ(NDAT,*) A(NOEL,20),A(NOEL,21)
      RETURN
      END
