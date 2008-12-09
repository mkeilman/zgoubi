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
      SUBROUTINE SPNTRK(IT,DS)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      COMMON/CHAVE/ B(5,3),V(5,3),E(5,3)
      COMMON/CONST/ CL9,CL ,PI,RAD,DEG,QE ,AMPROT, CM2M
      COMMON/PTICUL/ AM,Q,G,TO
      COMMON/RIGID/ BORO,DPREF,DP,BR
      INCLUDE "MAXTRA.H"
      COMMON/SPIN/ KSPN,KSO,SI(4,MXT),SF(4,MXT)
      COMMON/VITES/ U(6,3),DBR(6),DDT(6)
 
Correction, FM, 02/98 
CCC   DIMENSION BU(4,3), BP(4,3), O(4,3), S(5,3)
      DIMENSION BU(4,4), BP(4,3), O(4,3), S(5,3)
 
C      PM = BR*CL*1D-9/AM *(Q/QE)
C      PM = BR*CL*1D-9/AM *Q
      PM = BR*CL9/AM *Q
      GG = G * SQRT( 1.D0+PM*PM )
      GP = 1.D0+ GG
      GM = G-GG
 
CALCUL B.U, B.U', B.U'',B.U''', B'.U, B'.U',B'U'', B''.U, B''.U', B'''.U
      DO 1 IDB=1,4
        DO 1 IDU=1,5-IDB
          TEMP = 0.D0
          DO 2 I=1,3
            TEMP = TEMP + B(IDB,I)*U(IDU,I)
 2        CONTINUE
          BU(IDB,IDU) = TEMP
 1    CONTINUE
 
C       n              n    n           n
CALCUL d B-parallele/ds  = d ((B.U)U)/ds
      DO 5 I=1,3
        BP(1,I) =  BU(1,1) * U(1,I)
        DBU = BU(2,1)+BU(1,2)
        BP(2,I) = DBU * U(1,I) + BU(1,1) * U(2,I)
        D2BU = BU(3,1) + 2.D0*BU(2,2) + BU(1,3)
        BP(3,I) = D2BU*U(1,I) + 2.D0*DBU*U(2,I) + BU(1,1)*U(3,I)
        D3BU = BU(4,1) + 3.D0*( BU(3,2) + BU(2,3) ) + BU(1,4)
        BP(4,I) = D3BU*U(1,I) + 3.D0*( D2BU*U(2,I) 
     >   + DBU*U(3,I) ) + BU(1,1)*U(4,I)
 5    CONTINUE
 
CALCUL Omega
      DO 6 ID=1,4
        O(ID,1) = GP*B(ID,1) + GM*BP(ID,1)
        O(ID,2) = GP*B(ID,2) + GM*BP(ID,2)
        O(ID,3) = GP*B(ID,3) + GM*BP(ID,3)
 6    CONTINUE
 
      S(1,1) = SF(1,IT)
      S(1,2) = SF(2,IT)
      S(1,3) = SF(3,IT)
 
CALCUL S'=SxO
      S(2,1) = S(1,2)*O(1,3) - S(1,3)*O(1,2)
      S(2,2) = S(1,3)*O(1,1) - S(1,1)*O(1,3)
      S(2,3) = S(1,1)*O(1,2) - S(1,2)*O(1,1)
CALCUL S''=S'xO + SxO'
      S(3,1) = S(2,2)*O(1,3) - S(2,3)*O(1,2)
     >       + S(1,2)*O(2,3) - S(1,3)*O(2,2)
      S(3,2) = S(2,3)*O(1,1) - S(2,1)*O(1,3)
     >       + S(1,3)*O(2,1) - S(1,1)*O(2,3)
      S(3,3) = S(2,1)*O(1,2) - S(2,2)*O(1,1)
     >       + S(1,1)*O(2,2) - S(1,2)*O(2,1)
 
CALCUL S'''=S''xO + 2*S'xO' + SxO''
      S(4,1) = S(3,2)*O(1,3) - S(3,3)*O(1,2)
     >   + 2.D0*(S(2,2)*O(2,3) - S(2,3)*O(2,2))
     >       + S(1,2)*O(3,3) - S(1,3)*O(3,2)
      S(4,2) = S(3,3)*O(1,1) - S(3,1)*O(1,3)
     >   + 2.D0*(S(2,3)*O(2,1) - S(2,1)*O(2,3))
     >       + S(1,3)*O(3,1) - S(1,1)*O(3,3)
      S(4,3) = S(3,1)*O(1,2) - S(3,2)*O(1,1)
     >   + 2.D0*(S(2,1)*O(2,2) - S(2,2)*O(2,1))
     >       + S(1,1)*O(3,2) - S(1,2)*O(3,1)
 
CALCUL S''''=S'''xO + 3*S''xO' + 3*S'xO'' + SxO'''
      S(5,1) = S(4,2)*O(1,3) - S(4,3)*O(1,2)
     >   + 3.D0*(S(3,2)*O(2,3) - S(3,3)*O(2,2))
     >   + 3.D0*(S(2,2)*O(3,3) - S(2,3)*O(3,2))
     >       + S(1,2)*O(4,3) - S(1,3)*O(4,2)
      S(5,2) = S(4,3)*O(1,1) - S(4,1)*O(1,3)
     >   + 3.D0*(S(3,3)*O(2,1) - S(3,1)*O(2,3))
     >   + 3.D0*(S(2,3)*O(3,1) - S(2,1)*O(3,3))
     >       + S(1,3)*O(4,1) - S(1,1)*O(4,3)
      S(5,3) = S(4,1)*O(1,2) - S(4,2)*O(1,1)
     >   + 3.D0*(S(3,1)*O(2,2) - S(3,2)*O(2,1))
     >   + 3.D0*(S(2,1)*O(3,2) - S(2,2)*O(3,1))
     >       + S(1,1)*O(4,2) - S(1,2)*O(4,1)
 
C                                       2             3              4
CALCUL S(s+ds) = S(s) +S'(s)ds +S''(s)ds /2 +S'''(s)ds /6 +S''''(s)ds /24
      SF(1,IT)=S(1,1)+(S(2,1)+(S(3,1)/2.D0+(S(4,1)/6.D0+S(5,1)/24.D0*DS)
     >*DS)*DS)*DS
      SF(2,IT)=S(1,2)+(S(2,2)+(S(3,2)/2.D0+(S(4,2)/6.D0+S(5,2)/24.D0*DS)
     >*DS)*DS)*DS
C ERROR, corrctn DT Jan 2005
C     SF(3,IT)=S(1,3)+(S(2,3)+(S(3,3)/2.D0+(S(4,3)/6.D0+S(5,2)/24.D0*DS)
      SF(3,IT)=S(1,3)+(S(2,3)+(S(3,3)/2.D0+(S(4,3)/6.D0+S(5,3)/24.D0*DS)
     >*DS)*DS)*DS
      AN=SQRT(SF(1,IT)*SF(1,IT)+SF(2,IT)*SF(2,IT)+SF(3,IT)*SF(3,IT))
      SF(4,IT) = AN
 
C----- NORMALISATION
      SF(1,IT)=SF(1,IT)/AN
      SF(2,IT)=SF(2,IT)/AN
      SF(3,IT)=SF(3,IT)/AN
      SF(4,IT) = 1D0
 
      RETURN
      END