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
C  Fran�ois M�ot <fmeot@bnl.gov>
C  Brookhaven National Laboratory  
C  C-AD, Bldg 911
C  Upton, NY, 11973
C  -------
      SUBROUTINE AGSQUA(LMNT,MPOL,SCAL,
     >          DEV,RT,XL,BM,DLE,DLS,DE,DS,XE,XS,CE,CS)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER(*) LMNT(*)
      DIMENSION RT(*),BM(*),DLE(*),DLS(*),DE(MPOL,*),DS(MPOL,*)
      PARAMETER(MCOEF=6)
      DIMENSION CE(MCOEF), CS(MCOEF)
 
      COMMON/AIM/ BO,RO,FG,GF,XI,XF,EN,EB1,EB2,EG1,EG2
      COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      INCLUDE "MAXTRA.H"
      COMMON/CHAMBR/ LIMIT,IFORM,YLIM2,ZLIM2,SORT(MXT),FMAG,BMAX
     > ,YCH,ZCH
      COMMON/CONST/ CL9,CL ,PI,RAD,DEG,QEL,AMPROT, CM2M
      COMMON/CONST2/ ZERO, UN
      INCLUDE 'MXLD.H'
      COMMON/DON/ A(MXL,MXD),IQ(MXL),IP(MXL),NB,NOEL
      CHARACTER(80) TA
      COMMON/DONT/ TA(MXL,40)
      COMMON/DROITE/ CA(9),SA(9),CM(9),IDRT
      COMMON/EFBS/ AFB(2), BFB(2), CFB(2), IFB
      COMMON/INTEG/ PAS,DXI,XLIM,XCE,YCE,ALE,XCS,YCS,ALS,KP
      COMMON/REBELO/ NRBLT,IPASS,KWRT,NNDES,STDVM
      INCLUDE 'MXFS.H'
      COMMON/SCAL/ SCL(MXF,MXS),TIM(MXF,MXS),NTIM(MXF),KSCL

C----------- MIXFF = true if combined sharp edge multpole + fringe field multpole
      LOGICAL SKEW, MIXFF
     
      DIMENSION  AREG(2),BREG(2),CREG(2)
      PARAMETER (I2 = 2, I3 = 3)

      DATA MIXFF / .FALSE.  /

      CALL RAZ(BM,MPOL)

        XL =A(NOEL,10)
        RO =A(NOEL,11)
        GAP = RO/I2
        CUR1 =A(NOEL,12)
        CUR2 =A(NOEL,13)
        CUR3 =A(NOEL,14)
        DCUR1 =A(NOEL,15)
        DCUR2 =A(NOEL,16)
        DCUR3 =A(NOEL,17)

C------- Roll angle.  To be implemented
        RT(I2) =A(NOEL,60)
        SKEW = RT(I2) .NE. 0.D0
        RT(I2)=ZERO

        CALL AGSQKS(NOEL,CUR1,CUR2,CUR3,XL*CM2M,
     >                                          BBM)

        BM(I2) = BBM * SCAL

c           write(*,*) ' agsqua ',bbm, scal
c                read(*,*) 

        XE =A(NOEL,20)
        DLE(I2) =A(NOEL,21)

        CALL RAZ(CE,MCOEF)
        NCE = NINT(A(NOEL,30))
        DO I=1, NCE
          CE(I) =A(NOEL,30+I)
        ENDDO

        XLS =A(NOEL,40)
        DLS(I2) =A(NOEL,41)

C        IF(XE+XLS.GE.XL) 
C     >   CALL ENDJOB('SBR MULTIP : fringe field extent too long',-99)

        CALL RAZ(CS,MCOEF)
        NCS = NINT(A(NOEL,50))
        DO I=1,NCS
          CS(I) =A(NOEL,50+I)
        ENDDO
 
        DLE(I2)  = DLE(I2)*DLE(I2)
        DLS(I2)  = DLS(I2)*DLS(I2)
 
C              write(nlog,*) 'SBR MULTPO, ipass, bm(1)', ipass, bm(1)

      IF(NRES.GT.0) THEN
        WRITE(NRES,100) LMNT(I2),XL,RO
 100    FORMAT(/,5X,' -----  AGS ',A10,'  : ', 1P
     >  ,//,15X,' Length  of  element  = ',G16.8,'  cm'
     >  , /,15X,' Bore  radius      RO = ',G13.5,'  cm')
        WRITE(NRES,103) BM(I2)
 103    FORMAT(15X,' Field at pole tip  =',1P,G15.7,' kG')
        write(nres,fmt='(15X,3(A,1P,E13.5))') 
     >   ' Wind 1, I=',cur1,' ;   Wind 2, I=',cur2,' ;  Wind 3, I=',cur3
        IF(SKEW) WRITE(NRES,101) RT(I2)
 101    FORMAT(15X,' Skew  angle =',1P,G15.7,' rd')
        IF(XL .NE. 0.D0) THEN
          IF( (XL-DLE(I2)-DLS(I2)) .LT. 0.D0) WRITE(NRES,102)
 102      FORMAT(/,10X,'Entrance  &  exit  fringe  fields  overlap, ',
     >    /,10X,'  =>  computed  gradient  is ',' G = GE + GS - 1 ')
        ELSE
          GOTO 98
        ENDIF
      ENDIF
 
      DL0=0.D0
      SUM=0.D0

        DL0=DL0+DLE(I2)+DLS(I2)
        SUM=SUM+BM(I2)*BM(I2)
        IF(BM(I2).NE.0.D0) BM(I2) = BM(I2)/RO**(I2-1)

      IF(SUM .EQ. 0.D0) KFLD=KFLD-KFL
      IF(DL0 .EQ. 0.D0) THEN
C-------- Sharp edge at entrance and exit
        FINTE = XE
        XE=0.D0
        FINTS = XLS
        XLS=0.D0
        IF(NRES.GT.0) THEN
          WRITE(NRES,105) 'Entrance/exit field models are '
 105      FORMAT(/,15X,A,'sharp edge')
          WRITE(NRES,FMT='(15X,''FINTE, FINTS, gap : '',
     >    1P,3(1X,E12.4))') FINTE,FINTS,GAP
        ENDIF

            IF(XL .GT. 2.D0) THEN            
C FM, 2006
              CALL INTEG1(ZERO,FINTE,GAP)
              CALL INTEG2(ZERO,FINTS,GAP)
            ENDIF
        
      ELSE
C-------- Gradient G(s) at entrance or exit
C-----    Let's see entrance first
        IF(NRES.GT.0) WRITE(NRES,104)
 104    FORMAT(/,15X,' Entrance  face  ')
C 104    FORMAT(/,15X,' FACE  D''ENTREE  ')
        DL0 = 0.D0
        DL0 = DL0+DLE(I2)

        IF(DL0 .EQ. 0.D0) THEN
          FINTE = XE
          XE=0.D0
          IF(NRES.GT.0) THEN
            WRITE(NRES,105) 'Entrance field model is '
            WRITE(NRES,FMT='(15X,''FINTE, gap : '',
     >      1P,2(1X,E12.4))') FINTE,GAP
          ENDIF
          IF(XL .GT. 2.D0) CALL INTEG1(ZERO,FINTE,GAP)

        ELSE
C---------- IFB = 0 if no mixff
C----------     set to -1 if mixff at entrance
C----------     set to  1 if mixff at exit
C----------     set to  2 if mixff at entrance & exit
          IF( IFB .EQ. 0 .OR. IFB .EQ. 1 ) THEN
            MIXFF = .FALSE.
            IF(.NOT. MIXFF) THEN
C------------- MIXFF = true if combined sharp edge multpole + fringe field multpole
              IF(DLE(I2) .EQ. 0.D0 .AND. BM(I2) .NE. 0.D0)
     >          MIXFF= .TRUE.
            ENDIF

            IF(MIXFF) THEN
              IF(IFB .EQ. 0) THEN
                IFB = -1
              ELSE
                IFB = 2
              ENDIF
            ENDIF
          ENDIF

          IF(NRES.GT.0) THEN
            WRITE(NRES,130) XE
 130        FORMAT(20X,' with  fringe  field :'
C 130        FORMAT(20X,' AVEC  Champ  DE  FUITE  :'
     >      ,/,20X,' DX  = ',F7.3,'  CM ')
            WRITE(NRES,131) DLE(I2) 
 131        FORMAT(20X,' LAMBDA  =',F7.3,'  CM')
C            WRITE(NRES,132) (CE(I),I=1,6)
            WRITE(NRES,132) NCE, (CE(I),I=1,NCE)
 132        FORMAT(20X,I1,' COEFFICIENTS :',6F9.5)
          ENDIF

            IF(DLE(I2) .NE. 0.D0) THEN
              DE(I2,1)= -BM(I2)/DLE(I2)
C Error - Corrctn FM Nov. 2009
C              DO 44 I=2, 10 !MCOEF
              DO I=2, MCOEF
                DE(I2,I)=-DE(I2,I-1)/DLE(I2)
              ENDDO
            ENDIF

        ENDIF
 
C--------- Let's see exit, next
        IF(NRES.GT.0) WRITE(NRES,107)
 107    FORMAT(/,15X,' Exit  face  ')
C 107    FORMAT(/,15X,' FACE  DE  SORTIE  ')
 
        DL0 = 0.D0
        DL0 = DL0+DLS(I2)
        IF(DL0 .EQ. 0.D0) THEN
          FINTS = XLS
          XLS=0.D0
          IF(NRES.GT.0) THEN
            WRITE(NRES,105) 'Exit field model is '
            WRITE(NRES,FMT='(15X,''FINTS, gap : '',
     >      1P,2(1X,E12.4))') FINTS,GAP
          ENDIF
          IF(XL .GT. 2.D0) CALL INTEG2(ZERO,FINTS,GAP)

        ELSE
          IF( IFB .EQ. 0 .OR. IFB .EQ. -1 ) THEN
            MIXFF = .FALSE.
            IF(.NOT. MIXFF) THEN
              IF(DLS(I2) .EQ. 0.D0 .AND. BM(I2) .NE. 0.D0) 
     >         MIXFF= .TRUE.
            ENDIF

            IF(MIXFF) THEN
              IF(IFB .EQ. 0) THEN
                IFB = 1

              ELSE
                IFB = 2

              ENDIF
            ENDIF
          ENDIF
          IF(NRES.GT.0) THEN
            WRITE(NRES,130) XLS
            WRITE(NRES,131) DLS(I2)
            WRITE(NRES,132) NCS,(CS(I),I=1,NCS)
          ENDIF

            IF(DLS(I2) .NE. 0.D0) THEN
              DS(I2,1)=  BM(I2)/DLS(I2)
C Error - Corrctn FM Nov. 2009
C              DO 461 I=2, 10 !MCOEF
              DO I=2,MCOEF
                DS(I2,I)= DS(I2,I-1)/DLS(I2)
              ENDDO
            ENDIF

        ENDIF
 
      ENDIF
C---------- end of test DLE or DLS=0
 
      XI = 0.D0
      XLIM = XL + XE + XLS
      XF = XLIM
      XS = XL + XE
      SUM=0.D0

C----- Passage obligatoire sur les EFB's si
C       melange Mpoles-crenau + Mpoles-champ de fuite
      IF( IFB .EQ. -1 ) THEN
        AFB(1) = 1.D0
        BFB(1) = 0.D0
        CFB(1) = -XE         
      ELSEIF( IFB .EQ. 1 ) THEN
        AFB(2) = 1.D0
        BFB(2) = 0.D0
        CFB(2) = -XS       
      ELSEIF( IFB .EQ. 2 ) THEN
        AFB(1) = 1.D0
        BFB(1) = 0.D0
        CFB(1) = -XE       
        AFB(2) = 1.D0
        BFB(2) = 0.D0
        CFB(2) = -XS       
      ENDIF
C      IF( XE .GE. XL .OR. XLS .GE. XL ) THEN
C        IER = IER+1
C        TXT(IER) =  
C     >   'Overlapping of fringe fields is too large. Check XE, XS < XL'
C      ENDIF


          DEV= 0.D0
 
      CALL CHXC1R(
     >            KPAS)
      IF(KPAS.GE.1) THEN
        AREG(1)=1.D0
        BREG(1)=0.D0
        CREG(1)=-2.D0*XE
        AREG(2)=1.D0
        BREG(2)=0.D0
        CREG(2)=-2.D0*XS+XLIM
        CALL INTEG6(AREG,BREG,CREG)
      ENDIF

 98   RETURN
      END
