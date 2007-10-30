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
      SUBROUTINE RSCAL
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     ----------------------------------------------
C     READS DATA FOR POWER SUPPLIES OF LMNT FAMILIES
C     ----------------------------------------------
      COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      INCLUDE 'MXLD.H'
      COMMON/DON/ A(MXL,MXD),IQ(MXL),IP(MXL),NB,NOEL
      CHARACTER*80 TA
      COMMON/DONT/ TA(MXL,20)
      INCLUDE 'MXFS.H'
      COMMON/SCAL/SCL(MXF,MXS),TIM(MXF,MXS),NTIM(MXF),KSCL
      CHARACTER FAM*8,LBF*8,KLEY*10,LABEL*8
      PARAMETER (MXLBF=2)
      COMMON/SCALT/ FAM(MXF),LBF(MXF,MXLBF),KLEY,LABEL(MXL,2)
 
      PARAMETER(MST=MXLF+1)
      CHARACTER*10 STRA(MST)

      INTEGER DEBSTR, FINSTR

C----- IOPT; NB OF DIFFRNT FAMILIES TO BE SCALED (<= MXF)
      READ(NDAT,*) A(NOEL,1),A(NOEL,2) 

      NFAM = A(NOEL,2)
      IF(NFAM .GT. MXF) 
     >  CALL ENDJOB(' Too many families, maximum allowed is ',MXF)

      DO 1 IF=1,NFAM

C------- Store name of family and label(s)
        READ(NDAT,100)  TA(NOEL,IF)
 100    FORMAT(A80)
        TA(NOEL,IF) = 
     >    TA(NOEL,IF)(DEBSTR(TA(NOEL,IF)):FINSTR(TA(NOEL,IF)))
        CALL STRGET(TA(NOEL,IF),80,MST,
     >                                 NST,STRA)
        IF(NST-1 .GT. MXLBF) 
     >     CALL ENDJOB('Too many labels per family, max is ',MXLBF)

        FAM(IF) = STRA(1)    

        IF(NST .GE. 2) THEN
          DO 11 KL=2,NST
 11         LBF(IF,KL-1) =  STRA(KL)
        ENDIF

        DO 12 KL=NST+1, MST
 12       LBF(IF,KL-1) = ' '

        READ(NDAT,*) NTIM(IF)
        IF(NTIM(IF) .GT. MXS) 
     >     CALL ENDJOB('Too many timings, max is ',MXS)

        IF(NTIM(IF) .GE. 0) THEN
          NDSCL=NTIM(IF)
          NDTIM=NTIM(IF)
          MAX=NTIM(IF)

        ELSEIF(NTIM(IF) .LT. 0) THEN
          IF    (NTIM(IF) .EQ. -1) THEN
C---------- Field law protn driver, FNAL, Nov.2000 :
            NDSCL=4
            NDTIM=2
C               max = max(NDSCL,NDTIM)
            MAX=NDSCL  

          ELSEIF(NTIM(IF) .EQ. -2) THEN
C--------- Field law for scaling FFAG, LPSC, Sept. 2007
            NDSCL=1
            NDTIM=1
C               max = max(NDSCL,NDTIM)
            MAX=NDSCL  
          ENDIF
        ENDIF

C------- SCL(IF,IT)
        READ(NDAT,*) (A(NOEL,10*IF+IT-1),IT=1,NDSCL)
C------- TIM(IF,IT)
        READ(NDAT,*) (A(NOEL,10*IF+NDSCL+IT-1),IT=1,NDTIM)
        A(NOEL,10*IF+2*MAX) = NST
 1    CONTINUE
 
      RETURN
      END
