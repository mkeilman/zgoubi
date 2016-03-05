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
      SUBROUTINE RCHANG
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE "C.CDF.H"     ! COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      INCLUDE 'MXLD.H'
      INCLUDE "C.DON.H"     ! COMMON/DON/ A(MXL,MXD),IQ(MXL),IP(MXL),NB,NOEL
      INCLUDE "C.DONT.H"     ! COMMON/DONT/ TA(MXL,MXTA)

      CHARACTER(2) TXT2
      CHARACTER(1) TXT1
      CHARACTER(132) TXT

      INTEGER DEBSTR
      PARAMETER (MSR=8,MSR2=2*MSR)
      CHARACTER(30) SSHRO(MSR2)

      LINE = 1
      READ(NDAT,FMT='(A)',ERR=99,END=99) TXT
      TXT = TXT(DEBSTR(TXT):LEN(TXT))
      TXT1 = TXT(1:1)
      IF( TXT1.EQ.'X' .OR.
     >    TXT1.EQ.'Y' .OR. 
     >    TXT1.EQ.'Z'     ) THEN
C New style, x-, y-, z-shift or  x-, y-, z-rotation in arbitrary order
        CALL STRGET(TXT,MSR2,
     >                       NSR2,SSHRO)
        II = NSR2/2
        DO I=1,II
          TXT2 = SSHRO(2*I-1)(1:2)
          IF(TXT2(1:1).EQ.'X' .OR.
     >       TXT2(1:1).EQ.'Y' .OR.
     >       TXT2(1:1).EQ.'Z' ) THEN
            IF(TXT2(2:2).EQ.'S' .OR.
     >         TXT2(2:2).EQ.'R' ) THEN
              TA(NOEL,I) = TXT2
              READ(SSHRO(2*I),*) A(NOEL,I)
            ELSE
              NSR = II-1
              GOTO 10
            ENDIF
          ELSE
            NSR = II-1
            GOTO 10
          ENDIF
          IF(I.EQ.8 .OR. I.EQ.MXTA) THEN
            NSR = II
            GOTO 10
          ENDIF
        ENDDO
        NSR = II

 10     CONTINUE

C To allow for old style. 
c        TA(NOEL,4) = ' '
c yann prblem, erase the 4th transformation
      ELSE
C old style, x- and y-shift followed by z-rotation

        NSR = 3
        READ(TXT,*,ERR=99,END=99) (A(NOEL,I),I=1,NSR)
        TA(NOEL,1) = 'XS'
        TA(NOEL,2) = 'YS'
        TA(NOEL,3) = 'ZR'
        TA(NOEL,4) = 'OL'

      ENDIF

      IF(NSR .GT. MSR)
     >CALL ENDJOB('SBR RCHANG. Nmbr of transfrms must be .le. ',MSR)
      A(NOEL,9) = NSR

      RETURN

 99   WRITE(6,*) 
     >  ' *** Execution stopped upon READ : invalid input in CHANGREF'
      WRITE(NRES ,*) 
     >  ' *** Execution stopped upon READ : invalid input in CHANGREF'
      
      RETURN
      END
