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
      SUBROUTINE VRBLE(IER,II,KL,KP)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C----- CHERCHE SI LE PARMTRE VARIABLE COUPLE EST AUSSI DECLARE EN VARIABLE
      COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      PARAMETER (MXV=40) 
      COMMON/VARY/NV,IR(MXV),NC,I1(MXV),I2(MXV),V(MXV),IS(MXV),W(MXV),
     >IC(MXV),I3(MXV),XCOU(MXV),CPAR(MXV,7)
      IF(KL.LT.0) THEN
        KL=-KL
        KP=-KP
      ENDIF

      IF(NRES.GT.0) WRITE(NRES,101) IR(II),IS(II),KL,KP
 101  FORMAT(/10X,'VARIABLE  ELEMENT ',I4,',  PRMTR #',I3,' :'
     >,/,15X,'COUPLED  WITH  ELEMENT ',I4,',  PRMTR #',I3,/)
 
      DO 1 I=1,NV
        IF(I .EQ. II) GOTO 1
        IF(IR(I) .EQ. KL) THEN
          IF(IS(I) .EQ. KP) THEN
            IF(NRES.GT.0) WRITE(NRES,100) IR(I),IS(I),IR(II),IS(II)
 100        FORMAT(/10X,'BREAK  IN  SBR  FITEST :'
     >      ,//,10X,'REDUNDANT  DECLARATION  OF'
     >      ,2X,'VARIABLE  ( LMNT ',I4,',  PRMTR ',I3,' ) :'
     >      ,/ ,10X,'ALREADY  DECLARED  AS  COUPLED  IN  VARIABLE'
     >      ,2X,'LMNT ',I4,',  PRMTR ',I3,/)
            IER = 1
C            RETURN 1
          ENDIF
        ENDIF
 1    CONTINUE
      RETURN
      END