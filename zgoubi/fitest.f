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
      SUBROUTINE FITEST(*,IER)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      INCLUDE "MAXCOO.H"
      INCLUDE "MAXTRA.H"
      COMMON/FAISC/ F(MXJ,MXT),AMQ(5,MXT),IMAX,IEX(MXT),IREP(MXT)
      PARAMETER (MXV=40) 
      COMMON/VARY/NV,IR(MXV),NC,I1(MXV),I2(MXV),V(MXV),IS(MXV),W(MXV),
     >IC(MXV),I3(MXV),XCOU(MXV),CPAR(MXV,7)
      INCLUDE 'MXLD.H'
      COMMON/DON/ A(MXL,MXD),IQ(MXL),IP(MXL),NB,NOEL
 
      IER=0
C----- CONTROLE VARIABLES
      IF(NV.LT.1) IER=1
      IF(NV.GT.MXV)IER=1
      IF(IER .EQ. 1) THEN
        WRITE(NRES,102) '''NV''','VARIABLES'
 102    FORMAT(/,5X,' SBR  FITEST - WARNING *  DATA  ',A,
     >  '  IN ',A,'  IS  OUT  OF  RANGE')
      ENDIF
      DO 1 I=1,NV
C------- LMNT VARIABLE
        IF(IR(I).LT.1 .OR. IR(I).GE.NOEL) THEN
          WRITE(NRES,101) '''IR''',IR(I),'VARIABLE',I
 101      FORMAT(/,5X,' SBR  FITEST - WARNING *  data  ',A,'=',
     >    I2,'  in ',A,' #',I3,'  is  out  of  range')
          IER = 1
        ELSE
          WRITE(NRES,*) '          variable # ',I,
     >    '      IR = ',IR(I),',   ok.'
        ENDIF
 
C------- PARAMTRE VARIABLE DANS L'LMNT
        IF(IS(I).LT.1 .OR. IS(I).GT.MXD) THEN
          WRITE(NRES,101) '''IP''',IS(I),'VARIABLE',I
          IER = 1
        ELSE
          WRITE(NRES,*) '          variable # ',I,
     >    '      IP = ',IS(I),',   ok.'
        ENDIF
 
C------- COUPLAGE AVEC LMNT #KL, PRMTR #KP
        KL=XCOU(I)
        IF(KL .NE. 0) THEN
          KP=NINT((100.D0*XCOU(I)-100.D0*KL))
C          IF(KL.GT.0) KP=(NINT(100.D0*XCOU(I) + 1.D-6) - 100*KL)
C          IF(KL.LT.0) KP=(NINT(100.D0*XCOU(I) - 1.D-6) - 100*KL)
C          CALL VRBLE(*99,I,KL,KP)
          CALL VRBLE(IER,I,KL,KP)
C--------- # LMNT COUPLE
          IF(KL.GE.NOEL) THEN
            WRITE(NRES,101) '''XC.''',KL,'VARIABLE',I
            IER = 1
          ELSE
            WRITE(NRES,*) '          variable # ',I,
     >      '      XC.= ',KL,',   ok.'
          ENDIF
C--------- # PARAMETR COUPLE
          IF(KP .LT. 1 .OR. KP .GT. MXD) THEN
            WRITE(NRES,101) '''.XC''',KP,'VARIABLE',I
            IER = 1
          ELSE
            WRITE(NRES,*) '          variable # ',I,
     >      '      .XC= ',KP,',   ok.'
          ENDIF
        ENDIF
 1    CONTINUE
 
C----- CONTROLE CONTRAINTES
      IF(NC.LT.1 .OR. NC.GT.MXV) THEN
        WRITE(NRES,102) '''NC''','CONSTRAINTS'
        IER = 1
      ENDIF
 
      DO 8 I=1,NC
        IF(I3(I).LT. 1 .OR. I3(I).GE.NOEL ) THEN
          WRITE(NRES,101) '''IR''',I3(I),'CONSTRAINT',I
          IER = 1
        ELSE
          WRITE(NRES,*) '          constraint # ',I,
     >    '      IR = ',I3(I),',   ok.'
        ENDIF
        IF(IC(I) .EQ. 3) THEN
          IF(I1(I) .GT. IMAX ) THEN
            WRITE(NRES,101) '''I''',I1(I),'CONSTRAINT',I
            IER = 1
          ELSE
            WRITE(NRES,*) '          constraint # ',I,
     >      '      I  = ',I1(I),',   ok.'
          ENDIF
        ENDIF
 8    CONTINUE
 
      IF(IER .EQ. 1) THEN
        WRITE(NRES,FMT='(/,20X,''** NO  FIT  WILL  BE  PERFORMED **'')')
        RETURN 1
      ELSE
        WRITE(NRES,FMT='(/,20X,'' FIT  variables  in  good  order,'',  
     >              ''  FIT  will proceed. '')')
      ENDIF

      RETURN    
      END