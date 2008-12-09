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
      SUBROUTINE EVENT(DL,Y,T,Z,P,X,RZ,RX,RY,XAR,BR,SAR,TAR,KEX,IT,
     > AMT,QT,BORO,KART,KSPN,IFDES,KGA,KSYN,IMAX,*)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON/AIM/ ATO,AT,ATOS,RM,XI,XF,EN,EB1,EB2,EG1,EG2
      INCLUDE "MAXTRA.H"
      COMMON/CHAMBR/ LIMIT,IFORM,YL2,ZL2,SORT(MXT),FMAG,BMAX
     > ,YC,ZC

C----- in-flight decay
      IF(IFDES .EQ. 1)
     >  CALL MCDES(DL,KEX,Y,T,Z,P,X,BR,SAR,TAR,IT,AMT,QT,BORO,XAR,KART)
C     >  CALL MCDES(DL,KEX,Y,T,Z,P,RZ,BR,SAR,TAR,IT,AMT,QT,BORO,XAR,KART)

C----- gas-scattering
      BR0 = BR
      IF(KGA .EQ. 1) CALL GASCAT(DL,BR0,IT,
     >                                     BR,*99)

C------- Walls (chamber) 
      IF(LIMIT .EQ. 1) CALL CHMBRE(IT,Y,Z,SAR,
     >                                        KEX,*99)

C----- synchrotron radiation
      IF(KSYN .GE. 1 ) CALL RAYSYN(KSYN,DL,IT,IMAX)

      RETURN
 99   RETURN 1
      END