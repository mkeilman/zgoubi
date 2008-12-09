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
      FUNCTION RTNEWT(XB,YB,D,E,X1,X2,XACC,TTARF)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER (JMAX=10000)
C      RTNEWT=.5D0*(X1+X2)
      RTNEWT=X2
      DO 11 J=1,JMAX
         TEMP=RTNEWT
         CALL FUNCD(RTNEWT,XB,YB,D,E,F,DF,TTARF)
         DX=F/DF
C     DEB RAJOUT
         DXLIM=1.D0
         IF (ABS(DX).GT.DXLIM) THEN
            DX=0.1D0*(X1+X2)
C            write(*,*)'test ajout flo'
         ENDIF
C     FIN RAJOUT
         RTNEWT=RTNEWT-DX
         IF((X1-RTNEWT)*(RTNEWT-X2).LT.0.D0) THEN 
           RTNEWT=TEMP 
           RETURN   
         ENDIF

         IF(ABS(DX).LT.XACC) RETURN 
 11      CONTINUE
C      PAUSE 'rtnewt exceeding maximum iterations'
      RETURN
      END