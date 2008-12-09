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
      SUBROUTINE INITRA(I)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     ***COORDONNEES DE LA TRAJECTOIRE I ,INITIALISATION
      INCLUDE "MAXTRA.H"
      INCLUDE "MAXCOO.H"
      COMMON/FAISC/ F(MXJ,MXT),AMQ(5,MXT),IMAX,IEX(MXT),IREP(MXT)
      COMMON/PTICUL/ AM,Q,G,TO
      COMMON/RIGID/ BORO,DPREF,DP,BR
      COMMON/TRAJ/ Y,T,Z,P,X,SAR,TAR,KEX,IT,AMT,QT
      IT = I
      Y=F(2,I)
      T=F(3,I)*0.001D0
      Z=F(4,I)
      P=F(5,I)*0.001D0
      DP=F(1,I)
      BR=BORO*DP
      KEX=IEX(I)
      SAR= F(6,I)
      AMT = AMQ(1,I)
C----- AMQ(2,I) = Q/QE
      QT = AMQ(2,I)
      TAR = F(7,I)   *1.D5
      RETURN
      END