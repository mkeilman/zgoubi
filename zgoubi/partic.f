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
      SUBROUTINE PARTIC
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      COMMON/CONST/ CL9,CL ,PI,RAD,DEG,QE ,AMPROT, CM2M
      INCLUDE 'MXLD.H'
      COMMON/DON/ A(MXL,MXD),IQ(MXL),IP(MXL),NB,NOEL
      INCLUDE "MAXTRA.H"
      INCLUDE "MAXCOO.H"
      COMMON/FAISC/ F(MXJ,MXT),AMQ(5,MXT),IMAX,IEX(MXT),IREP(MXT)
C      COMMON/OBJET/ FO(MXJ,MXT),KOBJ,IDMAX,IMAXT
      COMMON/PTICUL/ AM,Q,G,TO
      COMMON/RIGID/ BORO,DPREF,DP,BR
      COMMON/UNITS/ UNIT(MXJ)

      CHARACTER CODE*11, CODEI*(*)
      SAVE CODE 
      DATA CODE / 'NONE' /

      LOGICAL FIRST 
      DATA FIRST / .TRUE. /
      SAVE FIRST 

      IF(.NOT. FIRST) RETURN
      FIRST = .FALSE.
     
      NM = 1
      NQ = 1

      AM = A(NOEL,1)

      IF(CODE(1:11) .EQ. 'MASS_CODE_1') THEN
        NM = 2
        AM2 = A(NOEL,2)
      ELSEIF(CODE(1:4) .NE. 'NONE') THEN
        GOTO 99
      ENDIF

      Q  = A(NOEL,NM+1) / QE
      G  = A(NOEL,NM+NQ+1)
      TO = A(NOEL,NM+NQ+2)
 
      DO 10 I=1,IMAX
        IF(NM.EQ.1) THEN
          AMQ(1,I) = AM
        ELSEIF(NM.EQ.2) THEN
          IF(I .LT. IMAX/2) THEN
            AMQ(1,I) = AM
          ELSE
            AMQ(1,I) = AM2
          ENDIF
        ENDIF
        AMQ(2,I) = Q
        AMQ(3,I) = G
        AMQ(4,I) = TO
 10   CONTINUE

C----- Set time at OBJET
      DO 11 I=1,IMAX
        IF(AMQ(1,I)*AMQ(2,I) .NE. 0.D0) THEN
C Err. Franck, Nov. 05
C          P = BORO*CL9*AMQ(2,I)
          P = BORO*CL9*AMQ(2,I) * F(1,I)
          AM2 = AMQ(1,I) * AMQ(1,I)
          BTA = P / SQRT(P*P + AM2)
          TIM = F(6,I)*UNIT(5) / (BTA * CL)
          F(7,I) = TIM / UNIT(7)
        ENDIF
 11   CONTINUE

      IF(NRES .GT. 0) THEN
        WRITE(NRES,FMT='(/,T6,''Particle  properties :'',/)')       
        IF(AM.NE.0.D0) THEN
          IF(NM .EQ. 1) THEN        
            WRITE(NRES,100) ' Mass          = ',AM, '  MeV/c2'
          ELSEIF(NM .EQ. 2) THEN 
            WRITE(NRES,100)'Type  1  mass      = ',AM, '  MeV/c2'
            WRITE(NRES,100)'Type  2  mass      = ',AM2,'  MeV/c2'
          ENDIF
        ENDIF
        WRITE(NRES,100)'Charge        = ',Q*QE , '  C     '
        IF(G.NE.0.D0)  WRITE(NRES,100)' G  factor     = ',G , '        '
        IF(TO.NE.0.D0) WRITE(NRES,100)' COM life-time = ',TO, '  s     '
 100    FORMAT(T20,A18,1P,G14.6,A10)
        IF(AM .NE. 0.D0) THEN 
          IF(Q .EQ. 0.D0) Q = 1
          PREF = BORO*CL9*Q
          ENRG = SQRT(PREF*PREF+AM*AM)
          BTA = PREF / ENRG
          GAM =  ENRG / AM
          WRITE(NRES,FMT='(/,1P,
     >    T15,''Reference  data :'',
     >    /,T15,''      rigidity (kG.cm)      :'',G14.6,
     >    /,T15,''      mass (MeV/c2)         :'',G14.6,
     >    /,T15,''      momentum (MeV/c)      :'',G14.6,
     >    /,T15,''      energy, total (MeV)   :'',G14.6,
     >    /,T15,''      energy, kinetic (MeV) :'',G14.6,
     >    /,T15,''      beta = v/c            :'',G18.10,
     >    /,T15,''      gamma                 :'',G18.10,
     >    /,T15,''      beta*gamma            :'',G18.10
     >       )') BORO,AM,PREF, ENRG, ENRG-AM, BTA, GAM, BTA*GAM
        ENDIF
      ENDIF

C Set time of flight now that mass and charge are known      
C      CALL SETTIM

      RETURN

      ENTRY PARTII(CODEI)
      CODE = CODEI
      RETURN

 99   STOP ' *** Error, SBR PARTIC-> mass encoding ***          '
      END