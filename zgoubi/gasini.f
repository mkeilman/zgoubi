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
      SUBROUTINE GASINI(*)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     --------------------------------------------
C     INITIALISE LES PARAMETRES NECESSAIRES A LA
C     GESTION DES DESINTEGRATIONS  EN COURS DE VOL
C     --------------------------------------------
      COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      INCLUDE 'MXLD.H'
      COMMON/DON/ A(MXL,MXD),IQ(MXL),IP(MXL),NB,NOEL
      COMMON/GASC/ AI, DEN, KGA
      COMMON/PTICUL/ AM,Q,G,TO
 
      KGA= A(NOEL,1)
      AI= A(NOEL,10)
      DEN = A(NOEL,11)

      IF(NRES.GT.0) THEN
        WRITE(NRES,100)
 100    FORMAT(10X,' ***** Gas scattering *****')

        WRITE(NRES,101) AI, DEN, KGA
 101    FORMAT(/,10X,'  Switch :', I1,
     >    /,10X,' AI : ',1P,G12.4,/,10X,' DEN :',G12.4,/)
      ENDIF

C      IF(AM*Q .EQ. 0.D0) THEN
      IF(Q*AM.EQ.0D0) THEN
        WRITE(NRES,106)
 106    FORMAT(//,15X,' PLEASE GIVE MASS OF FLYING PARTICLES !'
     >         ,/,15X,' - USE KEWORD ''PARTICUL''',/)
        RETURN 1
      ENDIF
 
      RETURN
      END