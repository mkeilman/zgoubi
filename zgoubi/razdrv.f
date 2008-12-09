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
      SUBROUTINE RAZDRV(IOP,IDB,IDE)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     --------------------------------------------------------
C     INITIALISATIONS DANS CHAMC.
C     INITIALISATIONS LIEES A L'ORDRE DE CALCUL ( 2, 25 OU 4 )
C     DU Champ B(X,Y,Z).
C     --------------------------------------------------------
      COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      COMMON/CHAMP/ BZ0(5,5), EZ0(5,5)
      COMMON/CHAVE/ B(5,3),V(5,3),E(5,3)
      COMMON/DDBXYZ/ DB(9),DDB(27)
      COMMON/D3BXYZ/ D3BX(27), D3BY(27), D3BZ(27)
      COMMON/D4BXYZ/ D4BX(81) ,D4BY(81) ,D4BZ(81)
      COMMON/DDEXYZ/ DE(9),DDE(27)
      COMMON/D3EXYZ/ D3EX(27), D3EY(27), D3EZ(27)
      COMMON/D4EXYZ/ D4EX(81) ,D4EY(81) ,D4EZ(81)

      GOTO (1,2,1) IOP
 
 1    CONTINUE

      DO 10 I=1,3
 10     B(1,I)=0.D0
      IF(IDB.GE.1) THEN
        DO 11 I=1,9
 11       DB(I)=0.D0
        IF(IDB.GE.2) THEN
          DO 12 I=1,27
 12         DDB(I)=0.D0
          IF(IDB.GE.3) THEN
            DO 13 I=1,27
              D3BX(I)=0.D0
              D3BY(I)=0.D0
              D3BZ(I)=0.D0
 13         CONTINUE
            IF(IDB.GE.4) THEN
              DO 14 I=1,81
                D4BX(I)=0.D0
                D4BY(I)=0.D0
                D4BZ(I)=0.D0
 14           CONTINUE
            ENDIF
          ENDIF
        ENDIF
      ENDIF

      DO 15 J=1,5
        DO 15 I=1,5
 15       BZ0(I,J) = 0.D0

      IF(IOP .EQ. 1) RETURN
 
 2    CONTINUE

      DO 20 I=1,3
 20     E(1,I)=0.D0
      IF(IDE.GE.1) THEN
        DO 21 I=1,9
 21       DE(I)=0.D0
        IF(IDE.GE.2) THEN
          DO 22 I=1,27
 22         DDE(I)=0.D0
          IF(IDE.GE.3) THEN
            DO 23 I=1,27
              D3EX(I)=0.D0
              D3EY(I)=0.D0
              D3EZ(I)=0.D0
 23         CONTINUE
            IF(IDE.GE.4) THEN
              DO 24 I=1,81
                D4EX(I)=0.D0
                D4EY(I)=0.D0
                D4EZ(I)=0.D0
 24           CONTINUE
            ENDIF
          ENDIF
        ENDIF
      ENDIF

      DO 25 J=1,5
        DO 25 I=1,5
 25       EZ0(I,J) = 0.D0

      RETURN
      END