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
      SUBROUTINE CHXP(ND,KALC,KUASEX,
     >                               XL,DSREF,NDD)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON/AIM/ AE,AT,AS,RM,XI,XF,EN,EB1,EB2,EG1,EG2
      INCLUDE 'PARIZ.H'
      COMMON//XH(MXX),YH(MXY),ZH(IZ),HC(ID,MXX,MXY,IZ),IAMA,JRMA,KZMA
      COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      INCLUDE 'MXLD.H'
      COMMON/DON/ A(MXL,MXD),IQ(MXL),IP(MXL),NB,NOEL
      COMMON/DROITE/ CA(9),SA(9),CM(9),IDRT
      COMMON/INTEG/ PAS,DXI,XLIM,XCE,YCE,ALE,XCS,YCS,ALS,KP
      LOGICAL ZSYM
      COMMON/OPTION/ KFLD,MG,LC,ML,ZSYM
      COMMON/ORDRES/ KORD,IRD,IDS,IDB,IDE,IDZ
      COMMON/PTICUL/ AM,Q,G,TO
      COMMON/REBELO/ NRBLT,IPASS,KWRT,NNDES,STDVM
      INCLUDE 'MXFS.H'
      COMMON/SCAL/SCL(MXF,MXS),TIM(MXF,MXS),NTIM(MXF),KSCL
      COMMON/STEP/ TPAS(3), KPAS
C      COMMON/STEP/ KPAS, TPAS(3) 
      COMMON/SYNRA/ KSYN
      COMMON/VITES/ U(6,3),DBR(6),DDT(6)
  
      CHARACTER TXTT*39, TXTS*39, TXTA*39, TXTEMP*11
      SAVE IPREC
      INCLUDE 'FILPLT.H'

      ZSYM=.TRUE.

C- KALC = TYPE CALCUL : ANALYTIQUE + SYM PLAN MEDIAN (1) , ANALYTIQUE 3D (3)
C   &  CARTE (2)
      IF    (KALC.EQ.2 ) THEN
C------- Field is defined by maps

        IF(KUASEX .EQ. 22) THEN
C--------- POLARMES keywords
          LF = NINT(A(NOEL,1))
C  LST=1(2) : PRINT step by step coord. and field in zgoubi.res (zgoubi.plt)
          LST =LSTSET(NINT(A(NOEL,2)))
          KP = NINT(A(NOEL,ND+10))
          NDD = ND+20
        ELSEIF(KUASEX .EQ. 20 .OR. KUASEX .EQ. 21) THEN
C--------- AIMANT, DIPOLE-M keywords
          LF =  NINT(A(NOEL,2))
          LST = LSTSET(NINT(A(NOEL,3)))
C Modif, FM, Dec. 05
C          KP = NINT(A(NOEL,ND+1))
C          NDD = ND+2
          KP = NINT(A(NOEL,ND+3))
          NDD = ND+4
        ELSEIF(KUASEX .EQ. 7 .OR. KUASEX .EQ. 2) THEN
C--------- TOSCA keywords using cylindrical mesh (MOD.ge.20)
          LF =  NINT(A(NOEL,1))
          LST =LSTSET(NINT(A(NOEL,2)))
          KP = NINT(A(NOEL,ND+10))
          NDD = ND+20
        ENDIF

      ELSE
C        KALC = 1 or 3
C        Field is defined by analytical models, mid plane (1) or 3D (3). 

        LF = 0
        LST =LSTSET(NINT(A(NOEL,1)))
        IF(KUASEX .EQ. 30) THEN
C--------- EMPTY

        ELSE

          KP = NINT(A(NOEL,ND+10))
          NDD = ND+11
        ENDIF

      ENDIF

      IF(LST.EQ.2 .OR. LST.GE.4) CALL OPEN2('CHXP',NPLT,FILPLT)

C----- FACTEUR D'ECHELLE DES ChampS. UTILISE PAR 'SCALING'
      SCAL = SCAL0()
      IF(KSCL .EQ. 1) SCAL = SCAL0()*SCALER(IPASS,NOEL,DTA1,DTA2,DTA3)

      AE = 0.D0
      AS = 0.D0
      IDRT = 0

        IDE=2
        IDB=2
        IDZ=2

      RFR = 0.D0

      GOTO (2001, 2002, 2003) KALC
 
 
 2001 CONTINUE
C----------- KALC = 1: Define field in the median plane 
C                  with median plane symetry

      IRD = KORD
      IF(IRD.EQ.4) IDB=4

      IF(KUASEX .EQ. 27 )   THEN
C-------- FFAG                ffag radial

        CALL FFAGI(SCAL,
     >                  DSREF,IRD,IDB)
C     >                  XL,DEV)
        IDZ=3
C Modif, FM, Dec. 05
C        KP = NINT(A(NOEL,ND+1))
C        NDD = ND+2
        KP = NINT(A(NOEL,ND+3))
        NDD = ND+4
C        DSREF = ABS(DEV * (XL/(2.D0 * SIN(DEV/2.D0))))

      ELSEIF(KUASEX .EQ. 30) THEN
C------- EMPTY

      ELSEIF(KUASEX .EQ. 31 )   THEN
C-------- DIPOLE

        CALL DIPI(SCAL,
     >                 DSREF)

C Modif, FM, Dec. 05
C        KP = NINT(A(NOEL,ND+1))
C        NDD = ND+2
        KP = NINT(A(NOEL,ND+3))
        NDD = ND+4
C        DSREF = ABS(DEV * (XL/(2.D0 * SIN(DEV/2.D0))))

      ELSEIF(KUASEX .EQ. 32 )   THEN
C-------- DIPOLES

        CALL DIPSI(SCAL,
     >                  DSREF,IRD,IDB)

C Modif, FM, Dec. 05
C        KP = NINT(A(NOEL,ND+1))
C        NDD = ND+2
        KP = NINT(A(NOEL,ND+3))
        NDD = ND+4
C        DSREF = ABS(DEV * (XL/(2.D0 * SIN(DEV/2.D0))))

      ELSEIF(KUASEX .EQ. 33 )   THEN
C-------- FFAG-SPI     spiral ffag

        CALL FFGSPI(SCAL,
     >                  DSREF,IRD,IDB)
C     >                  XL,DEV)
        IDZ=3

        KP = NINT(A(NOEL,ND+3))
        NDD = ND+4
C        DSREF = ABS(DEV * (XL/(2.D0 * SIN(DEV/2.D0))))

      ENDIF

      GOTO 99
 
C---------------------------------------------------------------
 2002 CONTINUE
C----- KALC = 2 : either read (TOSCAP, POLMES), or generate (CARLA, DIPOLM) a field map

      IF(KUASEX .EQ. 2) THEN
C TOSCA keyword with MOD.ge.20. 
        NDIM = 2
        CALL TOSCAP(SCAL,KUASEX,NDIM,
     >                          BMIN,BMAX,BNORM,
     >                          ABMI,RBMI,ZBMI,ABMA,RBMA,ZBMA)
        RFR = RM

      ELSEIF(KUASEX .EQ. 7) THEN
C TOSCA keyword with MOD.ge.20. 
        NDIM = 3
        CALL TOSCAP(SCAL,KUASEX,NDIM,
     >                          BMIN,BMAX,BNORM,
     >                          ABMI,RBMI,ZBMI,ABMA,RBMA,ZBMA)
        RFR = RM

      ELSEIF(KUASEX .EQ. 20) THEN
C AIMANT keyword

        CALL CARLA(SCAL,
     >                          BMIN,BMAX,BNORM,
     >                          ABMI,RBMI,ZBMI,ABMA,RBMA,ZBMA)
        NDIM = 2

      ELSEIF(KUASEX .EQ. 21) THEN
C DIPOLE-M keyword

        CALL DIPOLM(SCAL,
     >                          BMIN,BMAX,BNORM,
     >                          ABMI,RBMI,ZBMI,ABMA,RBMA,ZBMA)
        NDIM = 2
           write(*,*) ' sbr chxp ',A(NOEL,ND+3),A(NOEL,ND+4)
        IF(NINT(A(NOEL,ND+3)) .EQ. 2) RFR = A(NOEL,ND+4)

      ELSEIF(KUASEX .EQ. 22) THEN
C POLARMES keyword

        CALL POLMES(SCAL,KUASEX,
     >                          BMIN,BMAX,BNORM,
     >                          ABMI,RBMI,ZBMI,ABMA,RBMA,ZBMA)
        NDIM = 2
        RFR = RM

      ENDIF

      IF(NRES.GT.0) THEN
        WRITE(NRES,203) BMIN/BNORM,BMAX/BNORM,
     >      ABMI,RBMI,ZBMI,ABMA,RBMA,ZBMA, 
     >      BNORM,BMIN,BMAX,IAMA,JRMA,KZMA,
     >      XH(2)-XH(1),YH(2)-YH(1),ZH(2)-ZH(1)
  203   FORMAT(
     >    //,5X,' Min / max  fields  drawn  from  map  data : ', 
     >                           1P,G11.3,T80,' / ',G11.3,
     >    /,5X,'  @  A(rad),  R(cm), Z(cm) :              ', 
     >                             3G10.3,T80,' / ',3G10.3,
     >    /,5X,'Normalisation  coeff.  BNORM   :', G12.4,
     >    /,5X,'Field  min/max  normalised  :             ', 
     >                           1P,G11.3,T64,' / ',G11.3,
     >    /,5X,'Nbre of  steps  in  angle/radius/Z :',I4,'/',I4,'/',I4,
     >    /,5X,'Steps  in  angle/radius/Z :  ',G12.4,'/',
     >                  G12.4,'/',G12.4,'  (rad/cm/cm)')

        IF    (NDIM .EQ. 1) THEN
          WRITE(NRES,111) IRD
        ELSEIF(NDIM .EQ. 2) THEN
          WRITE(NRES,111) IRD
 111      FORMAT(/,20X,' Option  for  interpolation :',I2)
          IF(IRD .EQ. 2) THEN
            WRITE(NRES,113)
 113        FORMAT(20X,' Smoothing  using  9  points ')
          ELSE
C           .... IRD=4 OU 25
            WRITE(NRES,115)
 115        FORMAT(20X,' Smoothing  using  25  point ')
          ENDIF
        ELSEIF(NDIM .EQ. 3) THEN
          WRITE(NRES,119) IRD
 119      FORMAT(/,20X,' Option  for  interpolation :  3-D  grid',2X,
     >    '  3*3*3  points,   interpolation  at  ordre ',I2)
        ENDIF
 
        IF(LF .NE. 0) CALL FMAPW('CHXP',0.D0,RFR,2)
 
      ENDIF
C     ... endif NRES>0
 
      GOTO 99
 
C---------------------------------------------------------------
 2003 CONTINUE
C------- KALC = 3 : Full 3D calculation from analytical model 
C           ELCYLDEF

        IRD = KORD
        IF(IRD.EQ.4) IDB=4

        IF(KUASEX .EQ. 24)   THEN
C--------- ELCYLDEF
          CALL ELCYLD(SCAL,
     >                     XL)
C           Motion in this lmnt has no z-symm. 
          ZSYM=.FALSE.

        ELSEIF(KUASEX .EQ. 26 )   THEN
C--------- ELCMIR
          CALL ELCMII(SCAL,  
     >                     XL)
C           Motion in this lmnt has no z-symm. 
          ZSYM=.FALSE.

        ENDIF

 99   CONTINUE

      PAS = A(NOEL,ND)

      IF(KSCL .EQ. 1
C------ Cavity
     >               .OR. KSYN .EQ. 1) THEN
C--------------------- SR Loss
        IF(NRES .GT. 0)  WRITE(NRES,199) SCAL
 199    FORMAT(/,20X,'Field has been * by scaling factor ',1P,G16.8)
      ENDIF

      IF( KPAS .GT. 0 ) THEN
C------- Coded step size of form  #stp_1|stp_2|stp_3, stp_i= arbitrary integer
C                                    entr body exit
C      (max stp_i is MXSTEP as assigned in SBR INTEGR), 
C                      step size = length/stp_i
C------- KPAS=2 -> Variable step

C Modif, FM, Dec. 05
C        STP1 = A(NOEL,ND-2)
C        STP2 = A(NOEL,ND-1)
C        STP3 = A(NOEL,ND)
        STP1 = A(NOEL,ND)
        STP2 = A(NOEL,ND+1)
        STP3 = A(NOEL,ND+2)
        TPAS(1) = 2.D0 * AE * RM / STP1
        TPAS(2) =  (AT-2.D0 *(AE+AS))*RM / STP2
        TPAS(3) = 2.D0 *  AS * RM / STP3

        IF(NRES.GT.0) THEN
          WRITE(TXTA,FMT='(1P,'' / '',G11.3,'' / '')') TPAS(2)/RM
          WRITE(TXTS,FMT='(1P,'' / '',G11.3,'' / '')') TPAS(2)
          WRITE(TXTT,FMT='('' /   central   / '')') 
          IF(TPAS(1) .NE. 0.D0) THEN
            WRITE(TXTEMP,FMT='(1P,G11.3)') TPAS(1)/RM
            TXTA = TXTEMP//TXTA
            WRITE(TXTEMP,FMT='(1P,G11.3)') TPAS(1)
            TXTS = TXTEMP//TXTS
            TXTT = ' entrance  '//TXTT
          ENDIF 
          IF(TPAS(3) .NE. 0.D0) THEN
            WRITE(TXTEMP,FMT='(1P,G11.3)') TPAS(3)/RM
            TXTA = TXTA(1:17)//TXTEMP
            WRITE(TXTEMP,FMT='(1P,G11.3)') TPAS(3)
            TXTS = TXTS(1:17)//TXTEMP
            TXTT = TXTT(1:28)//'   exit    '
          ENDIF 

          WRITE(NRES,FMT='(/,25X,'' Integration  step :'')') 
          WRITE(NRES,FMT='(30X,A,'' (rad) '')') TXTA
          WRITE(NRES,FMT='(30X,A,'' (cm,  at mean radius)'')') TXTS
          WRITE(NRES,FMT='(30X,A,/,35X,''region'')') TXTT

          IF(KPAS .EQ. 2) THEN
              IF(NRES.GT.0)
     >         WRITE(NRES,FMT='(/,25X,'' ++ Variable step ++'',/,
     >            25X,'' PRECISION ='',1P,G12.4,/)') 10.D0**(-IPREC)
          ENDIF


        ENDIF

      ELSE

        IF(NRES.GT.0) WRITE(NRES,FMT='(/,20X,''Integration step :'',
     >    1P,G12.4,'' cm   (i.e., '',G12.4,'' rad  at mean radius)'')') 
     >      PAS, PAS/RM

      ENDIF

      IF(KFLD.GE.LC) THEN
        IF(Q*AM.EQ.0D0) 
     >  CALL ENDJOB('Give  mass  and  charge - keyword PARTICUL',-99)
      ENDIF

      RETURN

      ENTRY CHXP1R(
     >             KPASO)
      KPASO = KPAS
      RETURN
      ENTRY CHXP1W(KPASI,IPRECI)
      KPAS = KPASI
      IPREC = IPRECI
      IF(KPAS .EQ. 2) CALL DEPLAW(.TRUE.,IPREC)
      RETURN
 
      END